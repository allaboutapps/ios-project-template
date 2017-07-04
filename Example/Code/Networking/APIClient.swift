import Foundation
import Alamofire
import ReactiveSwift
import Result
import Moya
import ReactiveMoya
import Mapper
import ReactiveMapper

final class APIClient {
    
    fileprivate static var currentTokenRefresh: Signal<Moya.Response, MoyaError>?
    
    fileprivate static var _receivedBadCredentialsSignalObserver = Signal<Void, NoError>.pipe()
    static var receivedBadCredentialsSignal: Signal<Void, NoError> {
        return _receivedBadCredentialsSignalObserver.0
    }
    
    // MARK: Moya Configuration
    
    private static let endpointClosure = { (target: API) -> Endpoint<API> in
        let url = target.baseURL.appendingPathComponent(target.path).absoluteString
        
        var endpoint = Endpoint<API>(url: url,
                                     sampleResponseClosure: { .networkResponse(200, target.sampleData) },
                                     method: target.method,
                                     parameters: target.parameters,
                                     parameterEncoding: target.parameterEncoding)
        
        // Add authentication
        if let credentials = Credentials.currentCredentials?.accessToken {
            endpoint = endpoint.adding(newHTTPHeaderFields: ["Authorization": "Bearer \(credentials)"])
        }
        
        return endpoint
    }
    
    private static let stubClosure = { (target: API) -> StubBehavior in
        if Config.API.StubRequests {
            return .delayed(seconds: 1.0)
        }
        return .never
    }
    
    private static var provider: ReactiveSwiftMoyaProvider<API> = {
        let plugins: [PluginType] = {
            guard Config.API.NetworkLoggingEnabled else { return [] }
            let loggerPlugin = MoyaLoggerPlugin(verbose: Config.API.NetworkLoggingEnabled)
            return [loggerPlugin]
        }()
        
        return ReactiveSwiftMoyaProvider(endpointClosure: endpointClosure, stubClosure: stubClosure, plugins: plugins)
    }()
    
    // MARK: Request
    
    /// Performs the request on the given `target`
    static func request(_ target: API) -> SignalProducer<Moya.Response, APIError> {
        return request(target, authenticated: true)
            .filterSuccessfulStatusAndRedirectCodes()
            .mapError { APIError.moya($0, target) }
    }
    
    /**
     creates a new request
     
     - parameter target:        API target
     - parameter authenticated: specificies if this request should try to refresh the accesstoken in case of 401
     
     - returns: SignalProducer, representing task
     */
    private static func request(_ target: API, authenticated: Bool = true) -> SignalProducer<Moya.Response, MoyaError> {
        
        // setup initial request
        let initialRequest: SignalProducer<Moya.Response, MoyaError> = provider
            .request(target)
            .filterSuccessfulStatusAndRedirectCodes()
        
        // if the request should not care about authentication, skip token refresh arrangements
        if !authenticated {
            return initialRequest
        }
        
        // attaches the initial request to the current running token refresh request
        let attachRequestToCurrentRefresh: (Signal<Moya.Response, MoyaError>) -> SignalProducer<Moya.Response, MoyaError> = { refreshSignal in
            print("token refresh running -- attach new request to current token refresh request")
            return SignalProducer { (observer, _) in
                refreshSignal.observe(observer)
                }.flatMap(.latest) { _ -> SignalProducer<Moya.Response, MoyaError> in
                    return initialRequest
            }
        }
        
        // check if there is already a token refresh in progress -> enqueue new request
        if let currentTokenRefresh = currentTokenRefresh {
            return attachRequestToCurrentRefresh(currentTokenRefresh)
        }
            // if not, start the new request but
            // catch 401 to initiate a new accessToken refresh, but only if a refreshToken is available and no token refresh request is running
        else {
            return initialRequest.flatMapError { error in
                switch error {
                case .statusCode(let response):
                    if response.statusCode == 401 {
                        // check for a running token refresh request
                        if let currentTokenRefresh = currentTokenRefresh {
                            return attachRequestToCurrentRefresh(currentTokenRefresh)
                        }
                            // create a new token refresh request if a refreshToken is available
                        else {
                            if let refreshToken = Credentials.currentCredentials?.refreshToken {
                                return refreshAccessTokenWithRefreshToken(refreshToken).flatMap (.latest) { _ in
                                    return initialRequest
                                }
                            }
                        }
                    }
                default: break
                }
                
                // pass error if its not catched by refresh token procedure
                return SignalProducer(error: error)
            }
        }
    }
    
    /**
     refresh accessToken with refreshToken and save new Credentials
     
     - parameter refreshToken: refreshToken
     
     - returns: SignalProducer, representing the task
     */
    fileprivate static func refreshAccessTokenWithRefreshToken(_ refreshToken: String) -> SignalProducer<(), MoyaError> {
        
        let refeshRequest = SignalProducer<Response, MoyaError> { observer, disposable in
            
            disposable.add {
                currentTokenRefresh = nil
            }
            
            APIClient.provider
                .request(API.postRefreshToken(refreshToken: refreshToken))
                .filterSuccessfulStatusAndRedirectCodes()
                .startWithSignal { (signal, innerDisposable) in
                    self.currentTokenRefresh = signal
                    disposable.add(innerDisposable)
                    signal.observe(observer)
            }
        }
        
        return refeshRequest
            .mapJSON()
            .mapToType(Credentials.self)
            .on { credentials in
                Credentials.currentCredentials = credentials
            }
            .map { _ -> Void in
                return
            }
            .mapError { MoyaError.underlying($0) }
    }
    
}

// MARK: API Response Parsing

extension SignalProducerProtocol where Value == Moya.Response, Error == APIError {
    
    /// Parses the response to an object of the given `type`
    func parseAPIResponseType<T: Mappable>(_ type: T.Type, rootKeys: [String]? = nil) -> SignalProducer<T, APIError> {
        return mapJSON()
            .mapToType(type, rootKeys: rootKeys)
            .mapError(unboxAPIError)
    }
    
    /// Parses the response to an array of the given `type`
    func parseAPIResponseTypeArray<T: Mappable>(_ type: T.Type, rootKeys: [String]? = nil) -> SignalProducer<[T], APIError> {
        return mapJSON()
            .mapToTypeArray(type, rootKeys: rootKeys)
            .mapError(unboxAPIError)
    }
    
    private func unboxAPIError(error: ReactiveMapperError) -> APIError {
        switch error {
        case let .underlying(e) where e is APIError:
            return e as! APIError //swiftlint:disable:this force_cast
        default:
            return APIError.parser(error)
        }
    }
    
}

extension SignalProducerProtocol where Value == Response, Error == APIError {
    /// Maps data received from the signal into a JSON object. If the conversion fails, the signal errors.
    func mapJSON(failsOnEmptyData: Bool = false) -> SignalProducer<Any, APIError> {
        return producer.flatMap(.latest) { response -> SignalProducer<Any, APIError> in
            return unwrapThrowable { try response.mapJSON(failsOnEmptyData: failsOnEmptyData) }
        }
    }
}

/// Maps throwable to SignalProducer.
private func unwrapThrowable<T>(throwable: () throws -> T) -> SignalProducer<T, APIError> {
    do {
        return SignalProducer(value: try throwable())
    } catch {
        if let error = error as? APIError {
            return SignalProducer(error: error)
        } else {
            // The cast above should never fail, but just in case.
            return SignalProducer(error: APIError.underlying(error as NSError))
        }
    }
}
