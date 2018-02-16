import Foundation
import Moya

enum APIError: Swift.Error, LocalizedError {
    
    case moya(MoyaError, API)
    case underlying(Swift.Error)
    case invalidCredentials
    case other

    var errorDescription: String? {
        switch self {
        case let .moya(error, target):
            return localizedMoyaError(error: error, target: target)
        case .underlying:
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
                let nsError = error.0 as NSError
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

    private func localizedMoyaError(error: MoyaError, target: API) -> String {
        switch error {
        case let .statusCode(response):
            return localizedMoyaError(statusCode: response.statusCode, target: target)
        case let .underlying(error):
            let nsError = error.0 as NSError
            if nsError.code == -1009 || nsError.code == -1005 {
                return Strings.Network.errorNoConnection
            } else {
                return APIError.defaultLocalizedError
            }
        default:
            return APIError.defaultLocalizedError
        }
    }

    private func localizedMoyaError(statusCode: Int, target: API) -> String {
        switch (target, statusCode) {
        case (.postLogin, 422), (.postLogin, 400):
            return Strings.Network.errorWrongCredentials
//        case (.postForgotPassword, 404):
//            return Strings.Network.errorWrongEmail
//        case (.postForgotPassword, 462):
//            return Strings.Network.errorEmailSendFailed
//        case (.postRegister, 400):
//            return Strings.Network.errorWrongPayload
//        case (.postRegister, 409):
//            return Strings.Network.errorUsernameNotAvailable
//        case (.postRegister, 464), (.postChangePassword, 464):
//            return Strings.Network.errorWeakPassword
//        case (.postChangePassword, 465):
//            return Strings.Network.errorUnableToSetPassword

        default:
            if target.method == .get {
                return String(format: Strings.Network.errorLoadingFailed, "\(statusCode)")
            }
            return String(format: Strings.Network.errorPostingFailed, "\(statusCode)")
        }
    }

    private static var defaultLocalizedError = Strings.Network.errorGeneric
}
