//
//  AuthCoordinator.swift
//  Example
//
//  Created by Matthias Buchetics on 28.07.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

class AuthCoordinator: NavigationCoordinator {
    
    var onLogin: (() -> Void)?
    
    func start() {
        let viewController = LoginViewController.create()
        viewController.onLogin = onLogin

        push(viewController, animated: true)
    }
}
