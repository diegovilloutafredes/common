//
//  UIView+Show.swift
//

import UIKit

// MARK: - Show
extension UIView {
    
    /// Shows the view with optional animation.
    /// - Parameters:
    ///   - animated: Whether to animate. Defaults to `true`.
    ///   - duration: The animation duration.
    ///   - maxAlpha: The target alpha value. Defaults to `1`.
    ///   - completion: Completion handler.
    public func show(animated: Bool = true, with duration: TimeInterval = .DefaultValues.animationDuration, maxAlpha: CGFloat = 1, completion: CompletionHandler = nil) {
        guard isHidden else { return }

        alpha(.zero)

        guard animated else {
            isHidden = animated
            alpha = maxAlpha
            completion?()
            return
        }

        dispatchOnMain { [weak self] in guard let self else { return }
            UIView.animate(
                withDuration: duration,
                delay: .zero,
                options: .curveEaseIn,
                animations: {
                    self.isHidden = !animated
                    self.alpha = maxAlpha
                }
            ) { _ in completion?() }
        }
    }
}
