//
//  DebugViewController.swift
//  Example
//
//  Created by Michael Heinzl on 31.07.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

class DebugViewController: UIViewController {

    var onPush: (() -> Void)?
    var onPop: (() -> Void)?
    var onModal: (() -> Void)?
    var onDismiss: (() -> Void)?
    var onDebug: (() -> Void)?
    var onPushCoordinator: (() -> Void)?
    var onLogout: (() -> Void)?
    
    var viewModel: DebugViewModel!
    
    // MARK: Setup
    
    static func create(with viewModel: DebugViewModel) -> Self {
        let viewController = UIStoryboard(.debug).instantiateViewController(self)
        viewController.viewModel = viewModel
        return viewController
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    
    @IBAction func push(_ sender: Any) {
        self.onPush?()
    }
    
    @IBAction func pop(_ sender: Any) {
        self.onPop?()
    }
    
    @IBAction func modal(_ sender: Any) {
        self.onModal?()
    }

    @IBAction func dismiss(_ sender: Any) {
        self.onDismiss?()
    }
    
    @IBAction func debug(_ sender: Any) {
        self.onDebug?()
    }
    
    @IBAction func pushCoordinator(_ sender: Any) {
        self.onPushCoordinator?()
    }
    
    @IBAction func logout(_ sender: Any) {
        self.onLogout?()
    }
    
    deinit {
        print("deinit view controller: \(self)")
    }
    
}
