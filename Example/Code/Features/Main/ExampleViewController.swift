//
//  ExampleViewController.swift
//  Example
//
//  Created by Matthias Buchetics on 28.07.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController {

    var onMore: (() -> Void)?
    var onNext: (() -> Void)?
    var onDebug: (() -> Void)?
    var onTabBar: (() -> Void)?
    
    var viewModel: ExampleViewModel!
    
    // MARK: Setup
    
    static func createWith(storyboard: Storyboard, viewModel: ExampleViewModel) -> Self {
        let vc = UIStoryboard(storyboard).instantiateViewController(self)
        vc.viewModel = viewModel
        return vc
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = viewModel.title
    }
    
    // MARK: Actions
    
    @IBAction func showMore(_ sender: Any) {
        self.onMore?()
    }
    
    @IBAction func next(_ sender: Any) {
        self.onNext?()
    }
    
    @IBAction func debug(_ sender: Any) {
        self.onDebug?()
    }
    
    @IBAction func tabBar(_ sender: Any) {
        self.onTabBar?()
    }

    deinit {
        print("deinit view controller: \(self)")
    }
    
}
