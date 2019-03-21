import Foundation

class {{cookiecutter.projectName}}TabBarCoordinator: TabBarCoordinator {
    
    let coordinator1 = DebugCoordinator()
    let coordinator2 = DebugCoordinator()
    let coordinator3 = DebugCoordinator()
    
    func start() {
        coordinator1.start()
        coordinator2.start()
        coordinator3.start()
        
        addChild(coordinator1)
        addChild(coordinator2)
        addChild(coordinator3)
        
        tabBarController.viewControllers = [coordinator1.rootViewController, coordinator2.rootViewController, coordinator3.rootViewController]
    }
    
}
