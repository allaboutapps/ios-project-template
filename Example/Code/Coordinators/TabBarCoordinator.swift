//
//  TabBarCoordinator.swift
//  Example
//
//  Created by Matthias Buchetics on 30.07.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

class TabBarCoordinator: Coordinator {
    
    let tabBarController: UITabBarController
    
    init(tabBarController: UITabBarController = UITabBarController()) {
        self.tabBarController = tabBarController
        super.init(rootViewController: tabBarController)
        self.tabBarController.delegate = self
    }
    
    // MARK: - Debug
    
    override func debugInfo(level: Int = 0) -> String {
        var output = ""
        let tabs = String(repeating: "\t", count: level + 1)
        output += tabs + "* \(self)\n"
        if tabBarController.selectedIndex < childCoordinators.count {
            output += tabs + "- selected coordinator: \(childCoordinators[tabBarController.selectedIndex])\n"
        } else {
            output += tabs + "- selected index: \(tabBarController.selectedIndex)\n"
        }
        return output
    }
    
}

extension TabBarCoordinator: UITabBarControllerDelegate {
    
}
