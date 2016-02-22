import Foundation
import ReactiveMoya

/// Logs network activity (outgoing requests and incoming responses).
public class MoyaLoggerPlugin<Target: MoyaTarget>: Plugin<Target> {
    private let dateFormatString = "HH:mm:ss"
    private let dateFormatter = NSDateFormatter()
    
    /// If true, also logs response body data.
    public let verbose: Bool
    
    public init(verbose: Bool = false) {
        self.verbose = verbose
    }
    
    public override func willSendRequest(request: MoyaRequest, provider: MoyaProvider<Target>, target: Target) {
        logNetworkRequest(request.request, target: target)
    }
    
    public override func didReceiveResponse(data: NSData?, statusCode: Int?, response: NSURLResponse?, error: ErrorType?, provider: MoyaProvider<Target>, target: Target) {
        logNetworkResponse(response, data: data, target: target)
    }
    
}

private extension MoyaLoggerPlugin {
    
    private var date: String {
        dateFormatter.dateFormat = dateFormatString
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter.stringFromDate(NSDate())
    }
    
    func logNetworkRequest(request: NSURLRequest?, target: Target) {
        guard let request = request else {
            print("[%@] No Request", date)
            return
        }
        
        var output = [String]()
        
        // [21.12.2015] ↗️ GET http://example.com/foo
        output.append(String(format: "[%@] ↗️ %@ %@", date, request.HTTPMethod ?? "", request.URL?.absoluteString ?? ""))
        let spacing = "              "
        if let headers = request.allHTTPHeaderFields?.map({ "\(spacing)   \($0.0): \($0.1)" }).joinWithSeparator("\n") {
            output.append(String(format: "%@Headers: \n%@", spacing, headers))
        }
        
        if let body = prettyJSON(request.HTTPBody) where verbose == true {
            output.append(String(format: "%@Request Body: \n%@", spacing, body))
        }
        
        print(output.joinWithSeparator("\n"))
    }
    
    func logNetworkResponse(response: NSURLResponse?, data: NSData?, target: Target) {
        guard let response = response as? NSHTTPURLResponse else {
            print("[\(date)] 🔸 Received empty network response for <\(target)>.")
            return
        }
        
        var output = [String]()
        
        let range = 200...399
        let success = range.contains(response.statusCode) ? "✅" : "❌"
        output.append(String(format: "[%@] %@ %i %@", date, success, response.statusCode, response.URL?.absoluteString ?? ""))
        
        if let body = prettyJSON(data) where verbose == true {
            output.append(body)
        }
        
        print(output.joinWithSeparator("\n"))
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
