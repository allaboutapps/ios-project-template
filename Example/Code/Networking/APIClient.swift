import Foundation
import ReactiveCocoa
import ReactiveMoya
import Argo
import Argonaut

public class APIClient {
    
    private static let endpointClosure = { (target: API) -> Endpoint<API> in
        let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
        let endpoint = Endpoint<API>(URL: url, sampleResponseClosure: { .NetworkResponse(200, target.sampleData) }, method: target.method, parameters: target.parameters, parameterEncoding: .JSON)
        
        // Add Authorization header when available
//        if let token = Credentials().accessToken {
//            return endpoint.endpointByAddingHTTPHeaderFields(["Authorization": "Bearer \(token)"])
//        }
        return endpoint
    }
    
    private static let stubClosure = { (target: API) -> StubBehavior in
        if Config.APIStubRequests {
            return StubBehavior.Delayed(seconds: 2.0)
        }
        return StubBehavior.Never
    }
    
    static var provider: ReactiveCocoaMoyaProvider<API> = {
        let plugin = MoyaLoggerPlugin(verbose: Config.APIVerboseNetworkLogging)
        return ReactiveCocoaMoyaProvider(endpointClosure: endpointClosure, stubClosure: stubClosure, plugins: [plugin])
    }()
    
    
    // MARK: Request
    
    static func requestType<X: Decodable where X == X.DecodedType>(target: API, type: X.Type) -> SignalProducer<X, ArgonautError> {
        return provider.request(target)
            .mapJSON()
            .mapToType(type)
    }
    
    static func requestTypeArray<X: Decodable where X == X.DecodedType>(target: API, type: X.Type) -> SignalProducer<[X], ArgonautError> {
        return provider.request(target)
            .mapJSON()
            .mapToTypeArray(type)
    }
}
