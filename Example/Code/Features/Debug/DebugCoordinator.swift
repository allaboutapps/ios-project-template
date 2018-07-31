//
//  DebugCoordinator.swift
//  Example
//
//  Created by Michael Heinzl on 31.07.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import ExampleKit

class DebugCoordinator: NavigationCoordinator {
    
    var onDismiss: (() -> Void)?
    
    func start() {
        push()
    }
    
    private func push() {
        let viewModel = DebugViewModel(title: "Debug")
        let viewController = createDebugViewController(viewModel: viewModel)
        push(viewController, animated: true)
    }
    
    private func modal() {
        let coordinator = DebugCoordinator()
        coordinator.onDismiss = { [unowned self] in
           self.dismissChildCoordinator(animated: true)
        }
        coordinator.start()
        present(coordinator, animated: true)
    }
    
    private func pushCoordinator() {
        let coordinator = DebugCoordinator(navigationController: navigationController)
        coordinator.onDismiss = { [unowned self] in
            self.popCoordinator(animated: true)
        }
        coordinator.start()
        push(coordinator, animated: true)
    }
    
    private func createDebugViewController(viewModel: DebugViewModel) -> DebugViewController {
        let viewController = DebugViewController.create(with: viewModel)
        
        viewController.onModal = { [unowned self] in
            self.modal()
        }
        
        viewController.onPush = { [unowned self] in
            self.push()
        }
        
        viewController.onPop = { [unowned self] in
            self.popViewController(animated: true)
        }
        
        viewController.onPushCoordinator = { [unowned self] in
            self.pushCoordinator()
        }
        
        viewController.onDismiss = { [unowned self] in
            self.onDismiss?()
        }
        
        viewController.onDebug = { [unowned self] in
            self.printRootDebugStructure()
        }
        
        viewController.onLogout = {
            Credentials.currentCredentials = nil
        }
        
        return viewController
    }
    
}
