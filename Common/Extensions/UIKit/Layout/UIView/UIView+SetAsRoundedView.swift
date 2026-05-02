//
//  UIView+SetAsRoundedView.swift
//

import UIKit

// MARK: - Set as rounded view
extension UIView {

    /// Rounds the view into a circle/pill shape and returns self (chainable).
    /// - Parameters:
    ///   - maskedCorners: The corners to round. Defaults to `.all`.
    ///   - radius: The corner radius. If nil, uses half the height (pill shape), updated on every layout pass.
    ///   - animated: Whether to animate. Defaults to `false`.
    @discardableResult public func setAsRoundedView(using maskedCorners: CACornerMask = .all, radius: CGFloat? = nil, animated: Bool = false) -> Self {
        clipsToBounds(true)
        if let radius {
            if animated {
                onLayoutSubviews { [maskedCorners, radius] view in
                    UIView.animate(
                        withDuration: TimeInterval.DefaultValues.animationDuration,
                        delay: .zero,
                        options: .curveEaseInOut
                    ) { view.round(corners: maskedCorners, radius: radius) }
                }
            } else {
                round(corners: maskedCorners, radius: radius)
            }
        } else {
            schedulePillCornerRadius(using: maskedCorners, animated: animated)
        }
        return self
    }

    // Re-registers itself on every layout pass so the pill radius stays correct after rotation or resize.
    private func schedulePillCornerRadius(using maskedCorners: CACornerMask, animated: Bool) {
        onLayoutSubviews { [weak self] _ in
            guard let self else { return }
            let r = bounds.height / 2
            if layer.cornerRadius != r {
                if animated {
                    UIView.animate(
                        withDuration: TimeInterval.DefaultValues.animationDuration,
                        delay: .zero,
                        options: .curveEaseInOut
                    ) { self.round(corners: maskedCorners, radius: r) }
                } else {
                    round(corners: maskedCorners, radius: r)
                }
            }
            schedulePillCornerRadius(using: maskedCorners, animated: animated)
        }
    }
}
