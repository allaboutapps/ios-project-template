//
//  NavigationCoordinator.swift
//  Example
//
//  Created by Matthias Buchetics on 30.07.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import ExampleKit

class NavigationCoordinator: Coordinator {
    
    var pushedViewControllers: WeakArray<UIViewController>
    let navigationController: UINavigationController
    
    override var rootViewController: UIViewController {
        return navigationController
    }
    
    init(navigationController: UINavigationController = UINavigationController()) {
        self.pushedViewControllers = WeakArray([])
        self.navigationController = navigationController
        
        super.init()
        
        if self.navigationController.delegate == nil {
            self.navigationController.delegate = self
        }
    }
    
    func removePushedViewController(_ viewController: UIViewController) {
        if let index = pushedViewControllers.index(of: viewController) {
            pushedViewControllers.remove(at: index)
            print("remove: \(pushedViewControllers.count)")
            return
        }
        
        for coordinator in childCoordinators.compactMap({ $0 as? NavigationCoordinator }) {
            coordinator.removePushedViewController(viewController)
        }
    }
    
    override func removeAllChildren() {
        super.removeAllChildren()
        pushedViewControllers.removeAll()
    }
    
    // MARK: ViewController
    
    func push(_ viewController: UIViewController, animated: Bool) {
        pushedViewControllers.append(viewController)
        print("append: \(pushedViewControllers.count)")
        
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        navigationController.present(viewController, animated: animated, completion: completion)
    }
    
    func dismiss(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        viewController.presentingViewController?.dismiss(animated: animated, completion: completion)
    }
    
    // MARK: Coordinator
    
    func push(_ coordinator: Coordinator, animated: Bool) {
        addChild(coordinator)
    }
    
    func present(_ coordinator: Coordinator, animated: Bool, completion: (() -> Void)? = nil) {
        guard let viewController = coordinator.rootViewController else { return }
        
        addChild(coordinator)
        navigationController.present(viewController, animated: animated, completion: completion)
    }
    
    func dismiss(_ coordinator: Coordinator, animated: Bool, completion: (() -> Void)? = nil) {
        guard let viewController = coordinator.rootViewController else { return }
        
        print("dismiss coordinator")
        
        viewController.presentingViewController?.dismiss(animated: animated, completion: { [weak self] in
            self?.removeChild(coordinator)
            completion?()
        })
    }
}

// MARK: UINavigationControllerDelegate

extension NavigationCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // ensure the view controller is popping
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from), navigationController.viewControllers.contains(fromViewController) == false else {
            return
        }
        
        removeChild(for: fromViewController)
        removePushedViewController(fromViewController)
    }
}

// MARK: UIGestureRecognizerDelegate

extension NavigationCoordinator: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
