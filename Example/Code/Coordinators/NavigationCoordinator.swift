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
    
    // NavigationCoordinator can only have one child coordinator
    var childCoordinator: Coordinator? {
        return childCoordinators.first
    }
    
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
            print("remove: \(pushedViewControllers.count) from \(self)")
            if let parentCoordinator = parentCoordinator as? NavigationCoordinator, pushedViewControllers.isEmpty {
                parentCoordinator.removeChild(self)
                navigationController.delegate = parentCoordinator
            }
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
    
    func popViewController(animated: Bool) {
        if let viewController = navigationController.popViewController(animated: animated) {
            removePushedViewController(viewController)
        }
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
        if let navigationCoordinator = coordinator as? NavigationCoordinator {
            navigationController.delegate = navigationCoordinator // hand delegate to last coordinator
        }
    }
    
    func popCoordinator(animated: Bool) {
        if let lastViewController = pushedViewControllers[pushedViewControllers.count - 1] {
            navigationController.popToViewController(lastViewController, animated: animated)
        }
        if let childCoordinator = childCoordinator {
            removeChild(childCoordinator)
        }
        navigationController.delegate = self
    }
    
    func present(_ coordinator: Coordinator, animated: Bool, completion: (() -> Void)? = nil) {
        guard let viewController = coordinator.rootViewController else { return }
        
        addChild(coordinator)
        navigationController.present(viewController, animated: animated, completion: completion)
    }
    
    func dismissChildCoordinator(animated: Bool, completion: (() -> Void)? = nil) {
        guard let coordinator = childCoordinator,
            let viewController = coordinator.rootViewController else { return }
        
        print("dismiss coordinator")
        
        viewController.presentingViewController?.dismiss(animated: animated, completion: { [weak self] in
            self?.removeChild(coordinator)
            completion?()
        })
    }

    // MARK: - Debug
    override func debugInfo(level: Int = 0) -> String {
        var output = ""
        let tabs = String(repeating: "\t", count: level + 1)
        output += tabs + "* \(self)\n"
        
        let viewControllers = pushedViewControllers
            .compactMap { $0 }
            .map { String(describing: $0) }
            .joined(separator: ", ")
        output += tabs + "- VCs: [ \(viewControllers) ]\n"
        return output
    }
    
}

// MARK: UINavigationControllerDelegate

extension NavigationCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // ensure the view controller is popping
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
            navigationController.viewControllers.contains(fromViewController) == false
            else { return }
        
        removePushedViewController(fromViewController)
    }
}

// MARK: UIGestureRecognizerDelegate

extension NavigationCoordinator: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
