import UIKit
import {{cookiecutter.projectName}}Kit

class MoreCoordinator: NavigationCoordinator {
    
    var onDone: (() -> Void)?
    
    func start() {
        let viewController = MoreViewController.create()
        
        if onDone != nil {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        }

        push(viewController, animated: true)
    }
    
    @objc private func done() {
        onDone?()
    }
    
}
