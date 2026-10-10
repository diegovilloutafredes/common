//
//  Presentable.swift
//

import UIKit

// MARK: - PresentType
/// Defines the strategy for presenting a view controller.
public enum PresentType {
    /// Dismisses the current module before presenting the new one.
    case dismissingCurrent
    /// Presents the new module over the current one.
    case overCurrent
}

// MARK: - Presentable
/// A protocol for objects that can present modules (view controllers).
@MainActor
public protocol Presentable {
    
    /// Presents a view controller using the specified strategy.
    /// - Parameters:
    ///   - type: The presentation strategy to use.
    ///   - viewController: The view controller to present.
    ///   - animated: Whether to animate the presentation.
    ///   - completion: A closure to be called after the presentation finishes.
    func present(_ type: PresentType, viewController: UIViewController, animated: Bool, completion: CompletionHandler)
}

// MARK: - Default implementation
extension Presentable {
    @available(*, deprecated, message: "Use present, dismiss or presentAlertView, which honor presentationAnchor.")
    public var viewController: UIViewController? { presentationTarget }

    /// Where the default `present` goes without a presentation anchor: the application's top-most controller.
    var presentationTarget: UIViewController? { UIApplication.shared.topMostViewController }

    public func present(_ type: PresentType = .dismissingCurrent, viewController: UIViewController, animated: Bool = true, completion: CompletionHandler = nil) {
        if let anchor = anchorController(of: self) {
            return anchor.presentFromAnchor(type, viewController: viewController, animated: animated, completion: completion)
        }
        switch type {
        case .dismissingCurrent:
            presentationTarget?.dismiss(animated: animated) { present(.overCurrent, viewController: viewController, animated: animated, completion: completion) }
        case .overCurrent:
            presentationTarget?.present(viewController, animated: animated, completion: completion)
        }
    }
}

// MARK: - where Self: Navigationable
extension Presentable where Self: Navigationable {
    @available(*, deprecated, message: "Use present, dismiss or presentAlertView, which honor presentationAnchor.")
    public var viewController: UIViewController? { presentationTarget }

    /// Where the default `present` goes without a presentation anchor: the navigation controller.
    var presentationTarget: UIViewController? { navigationController }

    public func present(_ type: PresentType = .dismissingCurrent, viewController: UIViewController, animated: Bool = true, completion: CompletionHandler = nil) {
        if let anchor = anchorController(of: self) {
            return anchor.presentFromAnchor(type, viewController: viewController, animated: animated, completion: completion)
        }
        switch type {
        case .dismissingCurrent:
            presentationTarget?.dismissTopMostPresentedViewController(animated: animated) { present(.overCurrent, viewController: viewController, animated: animated, completion: completion) }
        case .overCurrent:
            (presentationTarget?.topMostPresentedViewController ?? presentationTarget)?.present(viewController, animated: animated, completion: completion)
        }
    }
}
