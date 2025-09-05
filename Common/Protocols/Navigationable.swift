//
//  Navigationable.swift
//

import UIKit

// MARK: - DismissType
public enum DismissType {
    case fromRoot
    case topMost
}

// MARK: - Dismissable
public protocol Dismissable {
    func dismiss(_ type: DismissType, animated: Bool, completion: CompletionHandler)
}

extension Dismissable {
    public var viewController: UIViewController? { UIApplication.shared.topMostViewController }

    public func dismiss(_ type: DismissType = .topMost, animated: Bool = true, completion: CompletionHandler = nil) {
        switch type {
        case .fromRoot: viewController?.dismissFromRootPresentingViewController(animated: animated, completion: completion)
        case .topMost: viewController?.dismissTopMostPresentedViewController(animated: animated, completion: completion)
        }
    }
}

// MARK: - where Self: Navigationable
extension Dismissable where Self: Navigationable {
    public var viewController: UIViewController? { navigationController }

    public func dismiss(_ type: DismissType = .topMost, animated: Bool = true, completion: CompletionHandler = nil) {
        switch type {
        case .fromRoot: viewController?.dismissFromRootPresentingViewController(animated: animated, completion: completion)
        case .topMost: viewController?.dismissTopMostPresentedViewController(animated: animated, completion: completion)
        }
    }
}





// MARK: - PresentType
public enum PresentType {
    case dismissingCurrent
    case overCurrent
}

// MARK: - Presentable
public protocol Presentable {
    func present(_ type: PresentType, viewController: UIViewController, animated: Bool, completion: CompletionHandler)
}

extension Presentable {
    public var viewController: UIViewController? { UIApplication.shared.topMostViewController }

    public func present(_ type: PresentType = .dismissingCurrent, viewController: UIViewController, animated: Bool = true, completion: CompletionHandler = nil) {
        switch type {
        case .dismissingCurrent:
            self.viewController?.dismiss(animated: animated) { present(.overCurrent, viewController: viewController, animated: animated, completion: completion) }
        case .overCurrent:
            self.viewController?.present(viewController, animated: animated, completion: completion)
        }
    }
}

// MARK: - where Self: Navigationable
extension Presentable where Self: Navigationable {
    public var viewController: UIViewController? { navigationController }

    public func present(_ type: PresentType = .dismissingCurrent, viewController: UIViewController, animated: Bool = true, completion: CompletionHandler = nil) {
        switch type {
        case .dismissingCurrent:
            self.viewController?.dismissTopMostPresentedViewController(animated: animated) { present(.overCurrent, viewController: viewController, animated: animated, completion: completion) }
//            self.viewController?.dismiss(animated: animated) { present(.overCurrent, viewController: viewController, animated: animated, completion: completion) }
        case .overCurrent:
            (self.viewController?.topMostPresentedViewController ?? self.viewController)?.present(viewController, animated: animated, completion: completion)
        }
    }
}





// MARK: - PopType
public enum PopType {
    case back
    case to(viewController: UIViewController)
    case toRoot
}

// MARK: - Navigationable
public protocol Navigationable {
    var navigationController: UINavigationController { get }
    func pop(_ type: PopType, animated: Bool)
    func push(_ viewController: UIViewController, animated: Bool)
    func set(_ viewController: UIViewController, animated: Bool)
    func set(_ viewControllers: [UIViewController], animated: Bool)
}

// MARK: - Default implementation
extension Navigationable {
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

    public func set(_ viewController: UIViewController, animated: Bool = false) { set([viewController], animated: animated) }

    public func set(_ viewControllers: [UIViewController], animated: Bool = false) {
        navigationController.setViewControllers(viewControllers, animated: animated)
    }
}
