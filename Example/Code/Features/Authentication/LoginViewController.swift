//
//  LoginViewController.swift
//  Example
//
//  Created by Matthias Buchetics on 28.07.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var onLogin: (() -> Void)?
    
    // MARK: Setup
    
    static func createWith(storyboard: Storyboard) -> Self {
        return UIStoryboard(storyboard).instantiateViewController(self)
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Login"
    }
    
    // MARK: Actions
    
    @IBAction func login(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "authenticated")
        self.onLogin?()
    }
}
