import Foundation
import ReactiveMoya
import Result

/// Logs network activity (outgoing requests and incoming responses).
public class MoyaLoggerPlugin: PluginType {
    private let dateFormatString = "HH:mm:ss"
    private let dateFormatter = NSDateFormatter()
    
    /// If true, also logs response body data.
    public let verbose: Bool
    
    public init(verbose: Bool = false) {
        self.verbose = verbose
    }
    
    public func willSendRequest(request: RequestType, target: TargetType) {
        logNetworkRequest(request.request, target: target)
    }
    
    public func didReceiveResponse(result: Result<Response, Error>, target: TargetType) {
        logNetworkResponse(result, target: target)
    }
    
}

private extension MoyaLoggerPlugin {
    
    private var date: String {
        dateFormatter.dateFormat = dateFormatString
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter.stringFromDate(NSDate())
    }
    
    func logNetworkRequest(request: NSURLRequest?, target: TargetType) {
        guard let request = request else {
            log.info("[%@] No Request", date)
            return
        }
        
        var output = [String]()
        
        // [10:13:54] ↗️ GET http://example.com/foo
        output.append(String(format: "[%@] ↗️ %@ %@", date, request.HTTPMethod ?? "", request.URL?.absoluteString ?? ""))
        let spacing = "              "
        if let headers = request.allHTTPHeaderFields?.map({ "\(spacing)   \($0.0): \($0.1)" }).joinWithSeparator("\n") {
            output.append(String(format: "%@Headers: \n%@", spacing, headers))
        }
        
        if let body = prettyJSON(request.HTTPBody) where verbose == true {
            output.append(String(format: "%@Request Body: \n%@", spacing, body))
        }
        
        log.info(output.joinWithSeparator("\n"))
    }
    
    func logNetworkResponse(response: Result<Response, Error>, target: TargetType) {
        switch response {
        case let .Success(value):
            guard let response = value.response as? NSHTTPURLResponse else {
                log.info("[\(date)] 🔸 Received empty network response for <\(target)>.")
                return
            }
            
            var output = [String]()
            
            let range = 200...399
            let success = range.contains(response.statusCode) ? "✅" : "❌"
            output.append(String(format: "[%@] %@ %i %@", date, success, response.statusCode, response.URL?.absoluteString ?? ""))
            
            if let body = prettyJSON(value.data) where verbose == true {
                output.append(body)
            }
            
            log.info(output.joinWithSeparator("\n"))
        case let .Failure(error):
            log.error("[%@] ❌ %@", date, String(error))
        }
    }
    
    private func prettyJSON(data: NSData?) -> String? {
        if let data = data,
            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
            let prettyJson = try? NSJSONSerialization.dataWithJSONObject(json, options: [.PrettyPrinted]),
            let string = NSString(data: prettyJson, encoding: NSUTF8StringEncoding) {
            return string as String
        }
        return nil
    }
}
