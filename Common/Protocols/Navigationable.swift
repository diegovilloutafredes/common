//
//  Navigationable.swift
//

import UIKit

// MARK: - PopType
public enum PopType {
    case back
    case to(viewController: UIViewController)
    case toRoot
}

// MARK: - Navigationable
public protocol Navigationable {
    var navigationController: UINavigationController { get }
    func dismiss(animated: Bool, completion: CompletionHandler)
    func pop(_ type: PopType, animated: Bool)
    func present(_ viewController: UIViewController, animated: Bool, completion: CompletionHandler)
    func push(_ viewController: UIViewController, animated: Bool)
    func set(_ viewControllers: [UIViewController], animated: Bool)
}

// MARK: - Default implementation
extension Navigationable {
    public func dismiss(animated: Bool = true, completion: CompletionHandler = nil) {
        navigationController.dismissPresentedViewController(animated: animated, completion: completion)
    }

    public func pop(_ type: PopType = .back, animated: Bool = true) {
        switch type {
        case .back:
            navigationController.popViewController(animated: animated)
        case .to(let viewController):
            navigationController.popToViewController(viewController, animated: animated)
        case .toRoot:
            navigationController.popToRootViewController(animated: animated)
        }
    }

    public func push(_ viewController: UIViewController, animated: Bool = true) {
        navigationController.pushViewController(viewController, animated: animated)
    }

    public func present(_ viewController: UIViewController, animated: Bool = true, completion: CompletionHandler = nil) {
        navigationController.present(viewController, animated: animated, completion: completion)
    }

    public func set(_ viewControllers: [UIViewController], animated: Bool = false) {
        navigationController.setViewControllers(viewControllers, animated: animated)
    }
}
