//
//  MoreCoordinator.swift
//  Example
//
//  Created by Matthias Buchetics on 29.07.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

class MoreCoordinator: NavigationCoordinator {
    
    var onDone: (() -> Void)?
    
    func start() {
        let viewController = MoreViewController.createWith(storyboard: .more)
        viewController.onLogout = showLogin
        
        if onDone != nil {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        }

        push(viewController, animated: true)
    }
    
    @objc private func done() {
        onDone?()
    }
    
    private func showLogin() {
        let coordinator = AuthCoordinator()
        
        coordinator.didLogin = { [unowned self] in
            self.removeChild(coordinator)
            AppCoordinator.shared.reset(animated: true)
        }
        
        coordinator.start()
        
        present(coordinator, animated: true, completion: nil)
    }
}
