//
//  Navigationable.swift
//

import UIKit

// MARK: - PopType
// MARK: - PopType
/// Defines the strategy for popping view controllers from a navigation stack.
public enum PopType {
    /// Pops the top-most view controller.
    case back
    /// Pops to a specific view controller.
    case to(viewController: UIViewController)
    /// Pops to the root view controller.
    case toRoot
}

// MARK: - Navigationable
/// A protocol for objects that can manage navigation stack operations.
public protocol Navigationable {
    
    /// The navigation controller used for navigation.
    var navigationController: UINavigationController { get }
    
    /// Pops view controllers from the navigation stack based on the specified strategy.
    /// - Parameters:
    ///   - type: The pop strategy to use.
    ///   - animated: Whether to animate the pop.
    func pop(_ type: PopType, animated: Bool)
    
    /// Pushes a view controller onto the navigation stack.
    /// - Parameters:
    ///   - viewController: The view controller to push.
    ///   - animated: Whether to animate the push.
    func push(_ viewController: UIViewController, animated: Bool)
    
    /// Sets the specified view controller as the root of the navigation stack.
    /// - Parameters:
    ///   - viewController: The view controller to set.
    ///   - animated: Whether to animate the transition.
    func set(_ viewController: UIViewController, animated: Bool)
    
    /// Sets the specified view controllers as the navigation stack.
    /// - Parameters:
    ///   - viewControllers: The array of view controllers to set.
    ///   - animated: Whether to animate the transition.
    func set(_ viewControllers: [UIViewController], animated: Bool)
}

// MARK: - Default implementation
extension Navigationable {
    public func pop(_ type: PopType = .back, animated: Bool = true) {
        switch type {
        case .back: navigationController.popViewController(animated: animated)
        case .to(let viewController): navigationController.popToViewController(viewController, animated: animated)
        case .toRoot: navigationController.popToRootViewController(animated: animated)
        }
    }

    public func push(_ viewController: UIViewController, animated: Bool = true) {
        navigationController.pushViewController(viewController, animated: animated)
    }

    public func set(_ viewController: UIViewController, animated: Bool = false) { set([viewController], animated: animated) }

    public func set(_ viewControllers: [UIViewController], animated: Bool = false) {
        navigationController.setViewControllers(viewControllers, animated: animated)
    }
}
