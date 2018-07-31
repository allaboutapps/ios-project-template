//
//  AppCoordinator.swift
//  Example
//
//  Created by Matthias Buchetics on 28.07.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

class AppCoordinator: NavigationCoordinator {
    
    static let shared = AppCoordinator()
    
    var window: UIWindow!
    
    init() {
        super.init(navigationController: UINavigationController())
    }
    
    func start(window: UIWindow) {
        self.window = window
        
        let coordinator = MainCoordinator(navigationController: navigationController)
        coordinator.start()
        
        childCoordinators.append(coordinator)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        if UserDefaults.standard.bool(forKey: "authenticated") == false {
            DispatchQueue.main.async {
                self.presentLogin(animated: false)
            }
        }
    }
    
    func reset(animated: Bool) {
        // remove all child coordinators besides the first one
        for coordinator in childCoordinators.dropFirst() {
            removeChild(coordinator)
        }
        
        // remove all children of the first coordinator as well
        if let firstCoordinator = childCoordinators.first {
            firstCoordinator.removeAllChildren()
        }
        
        navigationController.dismiss(animated: animated, completion: nil)
        navigationController.popToRootViewController(animated: false)
    }
    
    func showLogin() {
        if let viewController = window.topViewController() {
            print("hello")
        }
    }
    
    private func presentLogin(animated: Bool) {
        let coordinator = AuthCoordinator()
        
        coordinator.didLogin = { [unowned self] in
            self.dismiss(coordinator, animated: true)
        }
        
        coordinator.start()
        
        present(coordinator, animated: animated, completion: nil)
    }
}
