import Foundation
import Moya
import ReactiveMapper

typealias LocalizedError = String //(title: String, message: String)

enum APIError: Swift.Error {
    
    /// Moya error
    case moya(MoyaError, API)
    
    /// Argonaut Parser Error
    case parser(ReactiveMapperError)
    
    /// Underlying
    case underlying(Swift.Error)
    
    // Error Messages
    case invalidCredentials
    
    
    var localizedError: LocalizedError {
        switch self {
        case let .moya(error, target):
            return localizedNetworkError(error: error, target: target)
        case .parser, .underlying:
            return APIError.defaultLocalizedError
        default:
            return APIError.defaultLocalizedError
        }
    }
    
    var statusCode: Int? {
        switch self {
        case let .moya(error, _):
            switch error {
            case let .statusCode(response):
                return response.statusCode
            case let .underlying(error):
                let nsError = error as NSError
                return nsError.code
            default:
                return nil
            }
            
        case let .underlying(error):
            print(error)
            let nsError = error as NSError
            return nsError.code
        default:
            return nil
        }
    }
    
    // MARK: Helper
    
    private func localizedNetworkError(error: MoyaError, target: API) -> LocalizedError {
        switch error {
        case let .statusCode(response):
            return localizedNetworkErrorStatusCode(statusCode: response.statusCode, target: target)
        case let .underlying(error):
            let nsError = error as NSError
            if nsError.code == -1009 || nsError.code == -1005 {
                return Strings.Network.errorNoConnection
            }
            fallthrough
        default:
            return APIError.defaultLocalizedError
        }
    }
    
    private func localizedNetworkErrorStatusCode(statusCode: Int, target: API) -> LocalizedError {
        switch (target, statusCode) {
            
        case (.postLogin, 422), (.postLogin, 400):
            return Strings.Network.errorWrongCredentials
            
        default:
            if target.method == .get {
                return String(format: Strings.Network.errorLoadingFailed,"\(statusCode)")
            }
            return String(format: Strings.Network.errorPostingFailed, "\(statusCode)")
        }
    }
    
    private static var defaultLocalizedError: LocalizedError = Strings.Network.errorGeneric
}
