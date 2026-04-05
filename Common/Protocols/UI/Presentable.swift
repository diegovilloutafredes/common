//
//  Presentable.swift
//

import UIKit

// MARK: - PresentType
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
        case .overCurrent:
            (self.viewController?.topMostPresentedViewController ?? self.viewController)?.present(viewController, animated: animated, completion: completion)
        }
    }
}
