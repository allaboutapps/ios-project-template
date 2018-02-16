import Foundation
import Moya

enum API {
    // Login
    case postLogin(username: String, password: String)
    case postRefreshToken(refreshToken: String)
}

extension API: TargetType {
    var headers: [String: String]? {
        return nil
    }

    var baseURL: URL {
        return Config.API.BaseURL
    }

    var path: String {
        switch self {
        case .postLogin: return "api/v1/auth/token"
        case .postRefreshToken: return "api/v1/auth/token"
        }
    }

    var method: Moya.Method {
        switch self {
        case .postLogin,
             .postRefreshToken:
            return .post
            // default:
            //    return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case let .postLogin(username, password):
            let parameters = [
                "grantType": "password",
                "scope": "user",
                "username": username,
                "password": password
            ]

            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)

        case let .postRefreshToken(refreshToken):
            let parameters = [
                "grantType": "refreshToken",
                "scope": "user",
                "refreshToken": refreshToken
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)

            // default:
            //    return .requestPlain
        }
    }

    var shouldStub: Bool {
        switch self {
        default:
            return Config.API.StubRequests
        }
    }

    var sampleData: Data {
        switch self {
        case .postLogin:
            return stub("test")
        default:
            return Data()
        }
    }

    // Load stub data
    fileprivate func stub(_ name: String) -> Data {
        let path = Bundle(for: APIClient.self).path(forResource: name, ofType: "json")!
        return (try! Data(contentsOf: URL(fileURLWithPath: path)))
    }
}
