//
//  UIView+Hide.swift
//

import UIKit

// MARK: - Hide
extension UIView {
    
    /// Hides the view with optional animation.
    /// - Parameters:
    ///   - animated: Whether to animate. Defaults to `true`.
    ///   - duration: The animation duration.
    ///   - completion: Completion handler.
    public func hide(animated: Bool = true, with duration: TimeInterval = .DefaultValues.animationDuration, completion: CompletionHandler = nil) {
        guard isNotHidden else { return }

        guard animated else {
            alpha(.zero)
            isHidden(!animated)
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
                self.isHidden(animated)
                completion?()
            }
        }
    }
}
