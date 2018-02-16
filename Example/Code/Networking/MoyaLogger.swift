import Foundation
import Moya
import Result

/// Logs network activity (outgoing requests and incoming responses).
public class MoyaLoggerPlugin: PluginType {
    fileprivate let dateFormatString = "HH:mm:ss"
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = self.dateFormatString
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    /// If true, also logs response body data.
    public let verbose: Bool

    public typealias CustomLogClosure = ((_ timeStamp: Date, _ hash: String?, _ message: String, _ formattedMessage: String) -> Void)

    /// This closure can be used to customize logging. If not `nil`, this closure will be called each time
    /// the logger wants to log a string.
    /// The time stamp will be the time the log event occured.
    /// The hash can be used to match calls and responses in the log.
    /// If `nil` the logger will just print out the formatted message.
    public var customLogClosure: CustomLogClosure?

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
    func logNetworkRequest(request: URLRequest?, target: TargetType) {
        guard let request = request else {
            printMessage("No Request")
            return
        }

        var output = [String]()

        // [10:13:54] ↗️ GET http://example.com/foo
        output.append(String(format: "↗️ %@ %@", request.httpMethod ?? "", request.url?.absoluteString ?? ""))

        let spacing = "              "
        if let headers = request.allHTTPHeaderFields?.map({ "\(spacing)   \($0.0): \($0.1)" }).joined(separator: "\n"), verbose == true {
            output.append(String(format: "%@Headers: \n%@", spacing, headers))
        }

        if let body = prettyJSON(data: request.httpBody), verbose == true {
            output.append(String(format: "%@Request Body: \n%@", spacing, body))
        }

        printMessage(output.joined(separator: "\n"), hash: target.hashHex)
    }

    func logNetworkResponse(response: Result<Response, Moya.MoyaError>, target: TargetType) {
        switch response {
        case let .success(value):
            guard let response = value.response else {
                let icon = iconString("🔸", target)
                printMessage("\(icon) Received empty network response for <\(target)>.")
                return
            }

            var output = [String]()

            let range = 200 ... 399
            let icon = iconString(range.contains(response.statusCode) ? "✅" : "❌", target)

            output.append(String(format: "%@ %i %@", icon, response.statusCode, response.url?.absoluteString ?? ""))

            if let body = prettyJSON(data: value.data) ?? String(data: value.data, encoding: String.Encoding.utf8), verbose == true {
                output.append(body)
            }

            printMessage(output.joined(separator: "\n"), hash: target.hashHex)

        case let .failure(error):
            switch error {
            case let .underlying(e):
                let e = e.0 as NSError
                if e.code == -999 {
                    let icon = iconString("🔸", target)
                    printMessage("\(icon) Request Cancelled \(e.userInfo["NSErrorFailingURLStringKey"]!)")
                    return
                }
            default:
                break
            }

            let icon = iconString("❌", target)
            printMessage("\(icon) \(error)")
        }
    }

    private func iconString(_ icon: String, _ target: TargetType) -> String {
        let stubbed = (target as? API)?.shouldStub ?? false

        if stubbed {
            return "\(icon) [STUB]"
        } else {
            return icon
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

    private func printMessage(_ message: String, hash: String? = nil) {
        let now = Date()
        var formattedMessage = "[\(dateFormatter.string(from: now))] "
        if let hash = hash {
            formattedMessage += "(\(hash)) "
        }
        formattedMessage += "\(message)"

        if let customLogClosure = customLogClosure {
            customLogClosure(now, hash, message, formattedMessage)
        } else {
            print(formattedMessage)
        }
    }
}

extension TargetType {
    var hashValue: Int {
        var hashString = "\(method.hashValue)\(path.hashValue)"

        switch task {
        case let .requestParameters(parameters, encoding) where encoding is JSONEncoding:
            if let data = try? JSONSerialization.data(withJSONObject: parameters), let string = String(data: data, encoding: String.Encoding.utf8) {
                hashString += "\(string.hashValue)"
            }
        default:
            break
        }

        return hashString.hashValue
    }

    var hashHex: String {
        let value = UInt(truncatingIfNeeded: hashValue)
        return String(value, radix: 16, uppercase: true)
    }
}
