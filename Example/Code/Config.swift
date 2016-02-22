import Foundation

/// Global set of configuration values for this application.
struct Config {
    
    /// MARK: API
    
    static var APIBaseURL: NSURL {
        switch Environment.current() {
        case .Debug:
            return NSURL(string: "https://api.debug")!
        case .Release:
            return NSURL(string: "https://api.prod")!
        }
    }
    
    static let APIStubRequests = false
    static let APIVerboseNetworkLogging = false
}
