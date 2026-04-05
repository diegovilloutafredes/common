//
//  UIView+SetAsRoundedView.swift
//

import UIKit

// MARK: - Set as rounded view
extension UIView {
    
    /// Rounds the view into a circle/pill shape and returns self (chainable).
    /// - Parameters:
    ///   - maskedCorners: The corners to round. Defaults to `.all`.
    ///   - radius: The corner radius. If nil, uses half the height.
    ///   - animated: Whether to animate. Defaults to `false`.
    @discardableResult public func setAsRoundedView(using maskedCorners: CACornerMask = .all, radius: CGFloat? = nil, animated: Bool = false) -> Self {
        with { _ in
            dispatchOnMain { [weak self] in guard let self else { return }
                clipsToBounds(true)

                let animations: Action = { [weak self] in guard let self else { return }
                    round(corners: maskedCorners, radius: radius ?? frame.height / 2)
                }

                guard animated else { animations(); return }

                UIView.animate(
                    withDuration: .DefaultValues.animationDuration,
                    delay: .zero,
                    options: .curveEaseInOut,
                    animations: animations
                )
            }
        }
    }
}
