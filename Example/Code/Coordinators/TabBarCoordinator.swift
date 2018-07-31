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
    
    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
        super.init(rootViewController: tabBarController)
    }
    
}
