import UIKit

class MainCoordinator: NavigationCoordinator {
    
    func start() {
        let viewModel = {{cookiecutter.projectName}}ViewModel(title: "Main")
        let viewController = create{{cookiecutter.projectName}}ViewController(viewModel: viewModel)
        
        push(viewController, animated: true)
    }
    
    private func showNext(title: String) {
        let viewModel = {{cookiecutter.projectName}}ViewModel(title: title + ".Push")
        let viewController = create{{cookiecutter.projectName}}ViewController(viewModel: viewModel)
        
        push(viewController, animated: true)
    }
    
    private func create{{cookiecutter.projectName}}ViewController(viewModel: {{cookiecutter.projectName}}ViewModel) -> {{cookiecutter.projectName}}ViewController {
        let viewController = {{cookiecutter.projectName}}ViewController.createWith(storyboard: .main, viewModel: viewModel)
        
        viewController.onNext = { [unowned self] in
            self.showNext(title: viewModel.title)
        }
        
        viewController.onMore = { [unowned self] in
            self.showMoreModal()
        }
        
        viewController.onDebug = { [unowned self] in
            self.showDebug()
        }
        
        viewController.onTabBar = { [unowned self] in
            self.showTabBar()
        }
        
        return viewController
    }
    
    private func showMore() {
        let coordinator = MoreCoordinator(navigationController: navigationController)
        coordinator.start()
        
        push(coordinator, animated: true)
    }
    
    private func showDebug() {
        let coordinator = DebugCoordinator()
        coordinator.onDismiss = { [unowned self] in
            self.dismissChildCoordinator(animated: true)
        }
        coordinator.start()
        present(coordinator, animated: true)
    }
    
    private func showMoreModal() {
        let coordinator = MoreCoordinator()
        
        coordinator.onDone = { [unowned self] in
            self.dismissChildCoordinator(animated: true)
        }
        
        coordinator.start()
        
        present(coordinator, animated: true)
    }
    
    private func showTabBar() {
        let tabBarCoordinator = {{cookiecutter.projectName}}TabBarCoordinator()
        tabBarCoordinator.start()
        present(tabBarCoordinator, animated: true)
    }
    
}
