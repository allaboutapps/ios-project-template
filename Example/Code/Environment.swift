import Foundation

/// Defines the environment the app is currently running.
/// The environment is determined by the target's Configuration name, e.g. "Debug" or "Release".
/// You may want to add additional environments.
///
/// Make sure to add the "_Configuration" key with a value of "$(CONFIGURATION)" to your Info.plist file.
enum Environment: String {
    case Debug      = "Debug"
    case Release    = "Release"
    
    /// Returns the current enviroment the app is currently running.
    static func current() -> Environment {
        let configurationString = NSBundle.mainBundle().infoDictionary!["_Configuration"] as! String
        return Environment(rawValue: configurationString)!
    }
}
