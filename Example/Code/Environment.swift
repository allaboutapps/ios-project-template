import Foundation

/// Defines the environment the app is currently running.
/// The environment is determined by the target's Configuration name, e.g. "Debug" or "Release".
/// You may want to add additional environments.
///
/// Make sure to add the "_Configuration" key with a value of "$(CONFIGURATION)" to your Info.plist file.
enum Environment: String {
    case debug = "Debug"
    case release = "Release"

    /// Returns the current enviroment the app is currently running.
    static func current() -> Environment {
        guard
            let configurationString = Bundle.main.infoDictionary!["_Configuration"] as? String,
            let environment = Environment(rawValue: configurationString)
        else {
            fatalError("!!! No valid Environment !!!")
        }

        return environment
    }

    /// Returns the current App version, build number and environment
    /// e.g. `1.0 (3) Release`
    static var appInfo: String {
        guard let infoDict = Bundle.main.infoDictionary,
            let version = infoDict["CFBundleShortVersionString"],
            let build = infoDict["CFBundleVersion"] else {
            return ""
        }

        return "\(version) (\(build)) \(current().rawValue)"
    }
}

extension Environment: Equatable {}

func == (lhs: Environment, rhs: Environment) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
