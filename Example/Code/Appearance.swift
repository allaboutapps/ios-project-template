import UIKit

/// Defines the global appearance for the application.
struct Appearance {
    /// Sets the global appearance for the application.
    /// Call this method early in the applicaiton's setup, i.e. in `applicationDidFinishLaunching:`
    static func setup() {
        UINavigationBar.appearance().barTintColor = .red
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
}
