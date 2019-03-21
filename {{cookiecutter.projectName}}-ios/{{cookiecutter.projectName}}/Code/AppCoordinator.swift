import UIKit
import {{cookiecutter.projectName}}Kit
import ReactiveSwift

class AppCoordinator: Coordinator {
    
    static let shared = AppCoordinator()
    
    var window: UIWindow!
    let mainCoordinator = MainCoordinator()
    
    func start(window: UIWindow) {
        self.window = window
        
        mainCoordinator.start()
        addChild(mainCoordinator)
       
        window.rootViewController = mainCoordinator.rootViewController
        window.makeKeyAndVisible()
        
        printRootDebugStructure()
        
        checkCredentials(animated: false)
        Credentials.currentCredentialsChangedSignal.observeValues { [weak self] in
            self?.checkCredentials()
        }
        
    }
    
    func checkCredentials(animated: Bool = true) {
        if Credentials.currentCredentials == nil { // not logged in
            presentLogin(animated: animated)
        }
    }
    
    func reset(animated: Bool) {
        childCoordinators
            .filter { $0 !== mainCoordinator }
            .forEach { removeChild($0) }
        
        mainCoordinator.popToRoot(animated: animated)
        
        printRootDebugStructure()
    }
    
    private func presentLogin(animated: Bool) {
        let coordinator = AuthCoordinator()
        
        coordinator.onLogin = { [unowned self] in
            self.reset(animated: true)
        }
        
        coordinator.start()

        addChild(coordinator)
        window.topViewController()?.present(coordinator.rootViewController, animated: animated, completion: nil)
    }
    
}
