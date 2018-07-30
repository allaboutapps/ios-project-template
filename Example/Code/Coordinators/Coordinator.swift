//
//  NavigationCoordinator.swift
//  Example
//
//  Created by Matthias Buchetics on 29.07.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

// MARK: - Coordinator

class Coordinator: NSObject {
    
    var childCoordinators = [Coordinator]()
    var rootViewController: UIViewController? { return nil }
    
    func addChild(_ coordinator: Coordinator) {
        print("add child: \(String(describing: coordinator.self))")
        childCoordinators.append(coordinator)
    }
    
    func removeChild(_ coordinator: Coordinator) {
        if let index = childCoordinators.index(of: coordinator) {
            print("remove child: \(String(describing: coordinator.self))")
            childCoordinators.remove(at: index)
        }
    }
    
    func removeAllChildren() {
        for coordinator in childCoordinators {
            print("remove child: \(String(describing: coordinator.self))")
        }
        childCoordinators.removeAll()
    }
    
    @discardableResult func removeChild(for viewController: UIViewController) -> Bool {
        for coordinator in childCoordinators {
            if coordinator.removeChild(for: viewController) {
                return true
            }
        }
        
        for coordinator in childCoordinators.reversed() {
            if let navigationCoordinator = coordinator as? NavigationCoordinator, navigationCoordinator.pushedViewControllers.first == viewController {
                removeChild(coordinator)
                return true
            }
        }
        
        return false
    }
}
