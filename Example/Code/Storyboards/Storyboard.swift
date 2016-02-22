// see https://medium.com/swift-programming/uistoryboard-safer-with-enums-protocol-extensions-and-generics-7aad3883b44d

import UIKit

enum Storyboard: String {
    case LaunchScreen
    case Main
    /// ... your storyboard names
}


// MARK: StoryboardIdentifiable

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension UIViewController: StoryboardIdentifiable {}
extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(self)
    }
}


// MARK: UIStoryboard

extension UIStoryboard {
    
    /// Instantiates a storyboard given its identifier.
    convenience init(_ storyboard: Storyboard, bundle: NSBundle? = nil) {
        self.init(name: storyboard.rawValue, bundle: bundle)
    }
    
    /// Instantiates a typed view controller:
    /// ```
    /// let vc: SplashViewController = UIStoryboard(.Misc).instantiateViewController()
    /// ```
    func instantiateViewController<T: UIViewController where T: StoryboardIdentifiable>() -> T {
        guard let viewController = instantiateViewControllerWithIdentifier(T.storyboardIdentifier) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(T.storyboardIdentifier) in storyboard \(self)")
        }
        
        return viewController
    }
}
