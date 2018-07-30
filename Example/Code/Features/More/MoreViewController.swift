//
//  MoreViewController.swift
//  Example
//
//  Created by Matthias Buchetics on 29.07.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {
    
    var onLogout: (() -> Void)?
    
    // MARK: Setup
    
    static func createWith(storyboard: Storyboard) -> Self {
        return UIStoryboard(storyboard).instantiateViewController(self)
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "More"
    }
    
    // MARK: Actions
    
    @IBAction func logout(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "authenticated")
        self.onLogout?()
    }
}
