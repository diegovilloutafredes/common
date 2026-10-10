//
//  Dismissable.swift
//

import UIKit

// MARK: - DismissType
/// Defines the strategy for dismissing a view controller.
public enum DismissType: Sendable {
    /// Dismiss from the root presenting view controller.
    case fromRoot
    /// Dismiss the top-most presented view controller.
    case topMost
}

// MARK: - Dismissable
/// A protocol for objects that can manage the dismissal of view controllers.
@MainActor
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
    @available(*, deprecated, message: "Use present, dismiss or presentAlertView, which honor presentationAnchor.")
    public var viewController: UIViewController? { presentationTarget }

    /// Where the default `dismiss` goes without a presentation anchor: the application's top-most controller.
    var presentationTarget: UIViewController? { UIApplication.shared.topMostViewController }

    public func dismiss(_ type: DismissType = .topMost, animated: Bool = true, completion: CompletionHandler = nil) {
        if let anchor = anchorController(of: self) {
            return anchor.dismissFromAnchor(type, animated: animated, completion: completion)
        }
        switch type {
        case .fromRoot: presentationTarget?.dismissFromRootPresentingViewController(animated: animated, completion: completion)
        case .topMost: presentationTarget?.dismissTopMostPresentedViewController(animated: animated, completion: completion)
        }
    }
}

// MARK: - where Self: Navigationable
extension Dismissable where Self: Navigationable {
    @available(*, deprecated, message: "Use present, dismiss or presentAlertView, which honor presentationAnchor.")
    public var viewController: UIViewController? { presentationTarget }

    /// Where the default `dismiss` goes without a presentation anchor: the navigation controller.
    var presentationTarget: UIViewController? { navigationController }

    public func dismiss(_ type: DismissType = .topMost, animated: Bool = true, completion: CompletionHandler = nil) {
        if let anchor = anchorController(of: self) {
            return anchor.dismissFromAnchor(type, animated: animated, completion: completion)
        }
        switch type {
        case .fromRoot: presentationTarget?.dismissFromRootPresentingViewController(animated: animated, completion: completion)
        case .topMost: presentationTarget?.dismissTopMostPresentedViewController(animated: animated, completion: completion)
        }
    }
}
