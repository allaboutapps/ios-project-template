import UIKit

/// Defines the global appearance for the application. 
struct Appearance {

    /// Sets the global appearance for the application. 
    /// Call this method early in the applicaiton's setup, i.e. in `applicationDidFinishLaunching:`
    static func setup() {
        UINavigationBar.appearance().barTintColor = .redColor()
        UINavigationBar.appearance().tintColor = .whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
}