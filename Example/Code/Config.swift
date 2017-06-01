import Foundation

/// Global set of configuration values for this application.
struct Config {
    
    /// MARK: API
    
    struct API {
        
        static var BaseURL: URL {
            switch Environment.current() {
            case .debug:
                return URL(string: "https://api.debug")!
            case .release:
                return URL(string: "https://api.prod")!
            }
        }
        
        static let RandomStubRequests = false
        static let StubRequests = false
        static var TimeoutInterval: TimeInterval = 120.0
        
        static var NetworkLoggingEnabled: Bool {
            switch Environment.current() {
            case .debug:
                return true
            case .release:
                return false
            }
        }
        
        static var VerboseNetworkLogging: Bool {
            switch Environment.current() {
            case .debug:
                return true
            case .release:
                return false
            }
        }
    }
    
    struct Keychain {
        static let Service = "at.allaboutapps.example"
        static let CredentialsStorageKey = "Credentials"
    }
}
