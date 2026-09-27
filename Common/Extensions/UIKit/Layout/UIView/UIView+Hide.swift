//
//  UIView+Hide.swift
//

import UIKit

// MARK: - Hide
extension UIView {

    /// Hides the view with optional animation.
    ///
    /// The last `hide`/`show` call wins: a `show` made while this hide is still animating cancels its effect. The
    /// completion always runs exactly once, right away when the view is already hidden or hiding.
    /// - Parameters:
    ///   - animated: Whether to animate. Defaults to `true`.
    ///   - duration: The animation duration.
    ///   - completion: Completion handler.
    public func hide(animated: Bool = true, with duration: TimeInterval = .DefaultValues.animationDuration, completion: CompletionHandler = nil) {
        guard !isHiddenOrHiding else { completion?(); return }
        let generation = beginVisibilityTransition(toHidden: true)

        guard animated else {
            alpha(.zero)
            isHidden(true)
            _ = settleVisibilityTransition(generation)
            completion?()
            return
        }

        dispatchOnMain {
            UIView.animate(
                withDuration: duration,
                delay: .zero,
                options: .curveEaseOut,
                animations: { self.alpha(.zero) }
            ) { _ in
                if self.settleVisibilityTransition(generation) { self.isHidden(true) }
                completion?()
            }
        }
    }
}
