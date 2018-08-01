//
//  ExampleTabBarCoordinator.swift
//  Example
//
//  Created by Michael Heinzl on 01.08.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import Foundation

class ExampleTabBarCoordinator: TabBarCoordinator {
    
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
