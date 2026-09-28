//
//  PresentationAnchorProviding.swift
//

import UIKit

// MARK: - PresentationAnchorProviding
/// A type that names the controller its presentations, dismissals and alerts go through.
///
/// The default implementations of `Presentable`, `Dismissable` and `AlertPresentable` look for it. When a type that
/// adopts it returns a controller:
/// - presentations and alerts are presented from the top-most controller it presents, or from it when it presents
///   nothing
/// - dismissals dismiss the top-most controller it presents
///
/// `nil` keeps each protocol's own target: the navigation controller for a `Navigationable` type's presentations and
/// dismissals, and the application's top-most controller otherwise, for alerts included. `BaseCoordinator` adopts it
/// with an overridable `nil`. Any other presenting type can adopt it too, for example a view controller whose alerts a
/// test moves onto a controller it owns.
@MainActor
public protocol PresentationAnchorProviding: AnyObject {

    /// The controller presentations, dismissals and alerts go through, or `nil` for the defaults.
    var presentationAnchor: UIViewController? { get }
}

/// The anchor `presenter` names, when it adopts `PresentationAnchorProviding` and returns one. The three presenting
/// protocols look it up dynamically, so they gain no requirement and their existing conformers are untouched.
@MainActor
func anchorController(of presenter: Any) -> UIViewController? {
    (presenter as? any PresentationAnchorProviding)?.presentationAnchor
}

// MARK: - Presenting from an anchor
extension UIViewController {

    /// Presents as the default implementations do from an anchor: from the top-most controller this one presents.
    func presentFromAnchor(_ type: PresentType, viewController: UIViewController, animated: Bool, completion: CompletionHandler) {
        switch type {
        case .dismissingCurrent:
            dismissTopMostPresentedViewController(animated: animated) {
                self.presentFromAnchor(.overCurrent, viewController: viewController, animated: animated, completion: completion)
            }
        case .overCurrent:
            topMostPresentedViewController.present(viewController, animated: animated, completion: completion)
        }
    }

    /// Dismisses as the default implementations do through an anchor.
    func dismissFromAnchor(_ type: DismissType, animated: Bool, completion: CompletionHandler) {
        switch type {
        case .fromRoot: dismissFromRootPresentingViewController(animated: animated, completion: completion)
        case .topMost: dismissTopMostPresentedViewController(animated: animated, completion: completion)
        }
    }
}
