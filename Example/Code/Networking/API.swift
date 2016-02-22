import Foundation
import ReactiveMoya

enum API {
    case Test
    // ... your other API endpoints
}

extension API: TargetType {
    
    var baseURL: NSURL {
        return Config.APIBaseURL
    }
    
    var path: String {
        switch self {
        case .Test:
            return "/api/v1/test"
        }
    }
    
    var method: ReactiveMoya.Method {
        switch self {
        case .Test:
            return .POST
        default:
            return .GET
        }
    }
    
    var parameters: [String: AnyObject]? {
        switch self {
        case .Test:
            return ["foo": "bar", "baz": 1]
        default:
            return nil
        }
    }
    
    var sampleData: NSData {
        switch self {
        case .Test:
            return stub("test")
        }
    }
    
    // Load stub data
    private func stub(name: String) -> NSData {
        let path = NSBundle(forClass: APIClient.self).pathForResource(name, ofType: "json")!
        return NSData(contentsOfFile: path)!
    }
}
