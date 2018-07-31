//
//  AppCoordinator.swift
//  Example
//
//  Created by Matthias Buchetics on 28.07.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import ExampleKit
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
        
        Credentials.currentCredentialsChangedSignal.observeValues {
            if Credentials.currentCredentials == nil { // not logged in
                DispatchQueue.main.async {
                    self.presentLogin(animated: true)
                }
            }
        }
        
    }
    
    func reset(animated: Bool) {
        childCoordinators
            .filter { $0 !== mainCoordinator }
            .forEach { removeChild($0) }
        mainCoordinator.removeAllChildren()
        mainCoordinator.navigationController.dismiss(animated: animated, completion: nil)
        mainCoordinator.navigationController.popToRootViewController(animated: false)
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
