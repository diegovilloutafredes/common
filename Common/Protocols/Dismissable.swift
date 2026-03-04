//
//  Dismissable.swift
//

import UIKit

// MARK: - DismissType
// MARK: - DismissType
/// Defines the strategy for dismissing a view controller.
public enum DismissType {
    /// Dismiss from the root presenting view controller.
    case fromRoot
    /// Dismiss the top-most presented view controller.
    case topMost
}

// MARK: - Dismissable
/// A protocol for objects that can manage the dismissal of view controllers.
public protocol Dismissable {
    
    /// Dismisses a view controller using the specified strategy.
    /// - Parameters:
    ///   - type: The dismissal strategy to use.
    ///   - animated: Whether to animate the dismissal.
    ///   - completion: A closure to be called after the dismissal finishes.
    func dismiss(_ type: DismissType, animated: Bool, completion: CompletionHandler)
}

// MARK: - Default implementation
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
