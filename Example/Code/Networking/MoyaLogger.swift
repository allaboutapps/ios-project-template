import Foundation
import Moya
import Result

/// Logs network activity (outgoing requests and incoming responses).
public class MoyaLoggerPlugin: PluginType {
    
    fileprivate let dateFormatString = "HH:mm:ss"
    fileprivate let dateFormatter = DateFormatter()
    
    /// If true, also logs response body data.
    public let verbose: Bool
    
    public init(verbose: Bool = false) {
        self.verbose = verbose
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        logNetworkRequest(request: request.request, target: target)
    }
    
    public func didReceive(_ result: Result<Response, Moya.MoyaError>, target: TargetType) {
        logNetworkResponse(response: result, target: target)
    }
    
}

private extension MoyaLoggerPlugin {
    
    private var date: String {
        dateFormatter.dateFormat = dateFormatString
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: Date())
    }
    
    func logNetworkRequest(request: URLRequest?, target: TargetType) {
        guard let request = request else {
            print("[%@] No Request", date)
            return
        }
        
        var output = [String]()
        
        // [10:13:54] ↗️ GET http://example.com/foo
        output.append(String(format: "[%@] (%i) ↗️ %@ %@", date, target.hashValue, request.httpMethod ?? "", request.url?.absoluteString ?? ""))
        
        let spacing = "              "
        if let headers = request.allHTTPHeaderFields?.map({ "\(spacing)   \($0.0): \($0.1)" }).joined(separator: "\n"), verbose == true {
            output.append(String(format: "%@Headers: \n%@", spacing, headers))
        }
        
        if let body = prettyJSON(data: request.httpBody), verbose == true {
            output.append(String(format: "%@Request Body: \n%@", spacing, body))
        }
        
        print(output.joined(separator: "\n"))
    }
    
    func logNetworkResponse(response: Result<Response, Moya.MoyaError>, target: TargetType) {
        switch response {
        case let .success(value):
            guard let response = value.response as? HTTPURLResponse else {
                print("[\(date)] 🔸 Received empty network response for <\(target)>.")
                return
            }
            
            var output = [String]()
            
            let range = 200...399
            let success = range.contains(response.statusCode) ? "✅" : "❌"
            output.append(String(format: "[%@] (%i) %@ %i %@", date, target.hashValue, success, response.statusCode, response.url?.absoluteString ?? ""))
            
            if let body = prettyJSON(data: value.data) ?? String(data: value.data, encoding: String.Encoding.utf8), verbose == true {
                output.append(body)
            }
            
            print(output.joined(separator: "\n"))
        case let .failure(error):
            switch error {
            case let .underlying(e):
                let e = e as NSError
                if e.code == -999 {
                    print("[\(date)] 🔸 Request Cancelled \(e.userInfo["NSErrorFailingURLStringKey"]!)")
                    return
                }
                fallthrough
            default:
                print("[\(date)] ❌ \(error)")
            }
            
        }
    }
    
    private func prettyJSON(data: Data?) -> String? {
        if let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let prettyJson = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]),
            let string = NSString(data: prettyJson, encoding: String.Encoding.utf8.rawValue) {
            return string as String
        }
        return nil
    }
    
}

extension TargetType {
    
    var hashValue: Int {
        var hash = method.hashValue + path.hashValue
        if let jsonData = try? JSONSerialization.data(withJSONObject: parameters ?? [:], options: .prettyPrinted) {
            if let string = String(data: jsonData, encoding: String.Encoding.utf8) {
                let parameterHash = "\(string.hashValue)"
                let subString = parameterHash.substring(to: parameterHash.index(parameterHash.startIndex, offsetBy: 8))
                hash += Int(subString)!
            }
        }
        return hash
    }
    
}
