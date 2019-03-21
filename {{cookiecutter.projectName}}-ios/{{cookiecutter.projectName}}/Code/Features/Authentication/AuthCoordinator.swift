import UIKit

class AuthCoordinator: NavigationCoordinator {
    
    var onLogin: (() -> Void)?
    
    func start() {
        let viewController = LoginViewController.create()
        viewController.onLogin = onLogin

        push(viewController, animated: true)
    }
}
