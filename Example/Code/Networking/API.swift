import Foundation
import Moya

enum API {
    // Login
    case postLogin(username: String, password: String)
    case postRefreshToken(refreshToken: String)
}

extension API: TargetType {
    
    var baseURL: URL {
        return Config.API.BaseURL
    }
    
    var path: String {
        switch self {
        case .postLogin:            return "api/v1/auth/token"
        case .postRefreshToken:     return "api/v1/auth/token"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postLogin:            return .post
        case .postRefreshToken:     return .post
        default:                    return .get
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
            
        case let .postLogin(username, password):
            return [
                "grantType": "password",
                "scope": "user",
                "username": username,
                "password": password
            ]
            
        case let .postRefreshToken(refreshToken):
            return [
                "grantType": "refreshToken",
                "scope": "user",
                "refreshToken": refreshToken
            ]
            
        default:
            return nil
        }
    }

    var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    var task: Moya.Task {
        return .request
    }
    
    var multipartBody: [MultipartFormData]? {
        return nil
    }

    var sampleData: Data {
        switch self {
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
