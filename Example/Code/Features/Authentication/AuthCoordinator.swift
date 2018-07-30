//
//  AuthCoordinator.swift
//  Example
//
//  Created by Matthias Buchetics on 28.07.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

class AuthCoordinator: NavigationCoordinator {
    
    var didLogin: (() -> Void)?
    
    func start() {
        let viewController = LoginViewController.createWith(storyboard: .auth)
        viewController.onLogin = didLogin

        push(viewController, animated: true)
    }
}
