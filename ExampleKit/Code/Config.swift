import Foundation

/// Global set of configuration values for this application.
public struct Config {
    static let keyPrefix = "at.allaboutapps"

    // MARK: API

    public struct API {
        static var BaseURL: URL {
            switch Environment.current() {
            case .debug:
                return URL(string: "https://dev.allaboutapps.at")!
            case .release:
                return URL(string: "https://dev.allaboutapps.at")!
            }
        }

        static let RandomStubRequests = false
        static let StubRequests = true
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

    // MARK: User Defaults

    public struct UserDefaultsKey {
        static let lastUpdate = Config.keyPrefix + ".lastUpdate"
    }

    // MARK: Keychain

    public struct Keychain {
        static let credentialStorageKey = "CredentialsStorage"
        static let credentialsKey = "credentials"
    }
}
