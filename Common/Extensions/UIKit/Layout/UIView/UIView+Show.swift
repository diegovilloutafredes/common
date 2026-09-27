//
//  UIView+Show.swift
//

import UIKit

// MARK: - Show
extension UIView {

    /// Shows the view with optional animation.
    ///
    /// The last `hide`/`show` call wins: this show takes over from a hide that is still animating. The completion
    /// always runs exactly once, right away when the view is already visible or showing.
    /// - Parameters:
    ///   - animated: Whether to animate. Defaults to `true`.
    ///   - duration: The animation duration.
    ///   - maxAlpha: The target alpha value. Defaults to `1`.
    ///   - completion: Completion handler.
    public func show(animated: Bool = true, with duration: TimeInterval = .DefaultValues.animationDuration, maxAlpha: CGFloat = 1, completion: CompletionHandler = nil) {
        guard isHiddenOrHiding else { completion?(); return }
        let generation = beginVisibilityTransition(toHidden: false)

        alpha(.zero)

        guard animated else {
            isHidden = animated
            alpha = maxAlpha
            _ = settleVisibilityTransition(generation)
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
            ) { _ in
                _ = self.settleVisibilityTransition(generation)
                completion?()
            }
        }
    }
}
