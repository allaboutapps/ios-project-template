import Alamofire
import Foundation
import Moya
import ReactiveMoya
import ReactiveSwift
import Result

final class APIClient {
    fileprivate static var currentTokenRefresh: Signal<Moya.Response, MoyaError>?

    fileprivate static var _receivedBadCredentialsSignalObserver = Signal<Void, NoError>.pipe()
    static var receivedBadCredentialsSignal: Signal<Void, NoError> {
        return _receivedBadCredentialsSignalObserver.0
    }

    // MARK: Moya Configuration

    private static let endpointClosure = { (target: API) -> Endpoint in
        let url = target.baseURL.appendingPathComponent(target.path).absoluteString

        var endpoint = Endpoint(url: url,
                                sampleResponseClosure: { .networkResponse(200, target.sampleData) },
                                method: target.method,
                                task: target.task,
                                httpHeaderFields: target.headers)

        return endpoint
    }

    private static let stubClosure = { (target: API) -> StubBehavior in
        if target.shouldStub {
            return .delayed(seconds: 1.0)
        }
        return .never
    }

    private static var provider: MoyaProvider<API> = {
        let plugins: [PluginType] = {
            guard Config.API.NetworkLoggingEnabled else { return [] }
            let loggerPlugin = MoyaLoggerPlugin(verbose: Config.API.NetworkLoggingEnabled)
            return [loggerPlugin]
        }()

        return MoyaProvider(endpointClosure: endpointClosure, stubClosure: stubClosure, plugins: plugins)
    }()

    // MARK: Request

    /// Performs the request on the given `target`
    static func request(_ target: API) -> SignalProducer<Moya.Response, APIError> {
        return request(target, authenticated: true)
            .filterSuccessfulStatusAndRedirectCodes()
            .mapError { APIError.moya($0, target) }
    }

    /// Performs the request on the given `target` and maps the respsonse to the specific type (using Decodable).
    static func request<T: Decodable>(_ target: API, type: T.Type, keyPath: String? = nil, decoder: JSONDecoder = Decoders.standardJSON) -> SignalProducer<T, APIError> {
        return request(target, authenticated: true)
            .filterSuccessfulStatusAndRedirectCodes()
            .map(type, atKeyPath: keyPath, using: decoder)
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
            .reactive
            .request(target)
            .filterSuccessfulStatusAndRedirectCodes()

        // if the request should not care about authentication, skip token refresh arrangements
        if !authenticated {
            return initialRequest
        }

        // attaches the initial request to the current running token refresh request
        let attachRequestToCurrentRefresh: (Signal<Moya.Response, MoyaError>) -> SignalProducer<Moya.Response, MoyaError> = { refreshSignal in
            print("token refresh running -- attach new request to current token refresh request")
            return SignalProducer { observer, _ in
                refreshSignal.observe(observer)
            }
            .flatMap(.latest) { _ -> SignalProducer<Moya.Response, MoyaError> in
                initialRequest
            }
        }

        // check if there is already a token refresh in progress -> enqueue new request
        if let currentTokenRefresh = currentTokenRefresh {
            return attachRequestToCurrentRefresh(currentTokenRefresh)
        } else {
            // Check if we need to get access token first
            if let credentials = Credentials.currentCredentials,
                credentials.accessToken == "" {
                return refreshAccessTokenWithRefreshToken(credentials.refreshToken).flatMap(.latest) { _ in
                    initialRequest
                }
            }

            return initialRequest.flatMapError { error in
                switch error {
                case let .statusCode(response):
                    if response.statusCode == 401 {
                        // check for a running token refresh request
                        if let currentTokenRefresh = currentTokenRefresh {
                            return attachRequestToCurrentRefresh(currentTokenRefresh)
                        } else {
                            if let refreshToken = Credentials.currentCredentials?.refreshToken {
                                return refreshAccessTokenWithRefreshToken(refreshToken).flatMap(.latest) { _ in
                                    initialRequest
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
    static func refreshAccessTokenWithRefreshToken(_ refreshToken: String) -> SignalProducer<(), MoyaError> {
        let refreshRequest = SignalProducer<Response, MoyaError> { observer, disposable in

            disposable.observeEnded {
                currentTokenRefresh = nil
            }

            APIClient.provider
                .reactive
                .request(API.postRefreshToken(refreshToken: refreshToken))
                .filterSuccessfulStatusAndRedirectCodes()
                .startWithSignal { signal, innerDisposable in
                    self.currentTokenRefresh = signal
                    disposable.observeEnded {
                        innerDisposable.dispose()
                    }
                    signal.observe(observer)
                }
        }

        let logout = {
            Credentials.currentCredentials = nil
//            User.setCurrentUser(nil)
        }

        return refreshRequest
            .map(Credentials.self, using: Decoders.standardJSON)
            .on(value: { credentials in
                Credentials.currentCredentials = credentials
            })
            .on(failed: { error in
                // Check if we need to ignore network errors, else log out
                if let osError = APIClient.unwrapUnderlyingError(error: error) {
                    if osError.domain != NSURLErrorDomain {
                        logout()
                    }
                } else {
                    logout()
                }
            })
            .map { _ -> Void in
                return
            }
            .mapError {
                MoyaError.underlying($0, nil)
            }
    }

    private static func unwrapUnderlyingError(error: MoyaError) -> NSError? {
        switch error {
        case let .objectMapping(error, _):
            return error as NSError
        case let .encodableMapping(error):
            return error as NSError
        case let .underlying(error, _):
            return error as NSError
        case let .parameterEncoding(error):
            return error as NSError
        default:
            return nil
        }
    }
}
