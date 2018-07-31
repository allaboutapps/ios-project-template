//
//  MoreViewController.swift
//  Example
//
//  Created by Matthias Buchetics on 29.07.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import ExampleKit

class MoreViewController: UIViewController {
    
    // MARK: Setup
    
    static func create() -> Self {
        return UIStoryboard(.more).instantiateViewController(self)
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "More"
    }
    
    // MARK: Actions
    
    @IBAction func logout(_ sender: Any) {
        Credentials.currentCredentials = nil
    }
    
    deinit {
        print("deinit view controller: \(self)")
    }
    
}
