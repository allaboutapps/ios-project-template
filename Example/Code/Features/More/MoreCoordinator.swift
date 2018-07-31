//
//  MoreCoordinator.swift
//  Example
//
//  Created by Matthias Buchetics on 29.07.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import ExampleKit

class MoreCoordinator: NavigationCoordinator {
    
    var onDone: (() -> Void)?
    
    func start() {
        let viewController = MoreViewController.create()
        
        if onDone != nil {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        }

        push(viewController, animated: true)
    }
    
    @objc private func done() {
        onDone?()
    }
    
}
