//
//  UIView+SetAsRoundedView.swift
//

import UIKit

// MARK: - Set as rounded view
extension UIView {

    /// Rounds the view's corners.
    ///
    /// - When `radius` is given, the rounding is applied once synchronously
    ///   and any previous pill tracking on the view is disabled.
    /// - When `radius` is `nil`, the view enters pill mode: `cornerRadius` is
    ///   updated to `bounds.height / 2` on every layout pass for the lifetime
    ///   of the view, so it stays a perfect pill across resize and rotation.
    ///   If `bounds.height` is already valid at the call site, the radius is
    ///   *also* applied immediately — so calling this from inside a
    ///   `layoutSubviews` override or another `onLayoutSubviews` handler still
    ///   renders correctly on the first paint.
    ///
    /// Both modes set `clipsToBounds = true`.
    /// - Parameters:
    ///   - maskedCorners: The corners to round. Defaults to `.all`.
    ///   - radius: An explicit radius; if `nil`, the view behaves as a pill.
    @discardableResult public func setAsRoundedView(using maskedCorners: CACornerMask = .all, radius: CGFloat? = nil) -> Self {
        clipsToBounds(true)
        if let radius {
            _pillBehavior = false
            round(corners: maskedCorners, radius: radius)
        } else {
            _pillCorners = maskedCorners
            _pillBehavior = true
            // Synchronous first-paint correctness: if the call site is inside a
            // layoutSubviews override or another onLayoutSubviews handler, bounds
            // are already valid here — apply immediately so the view never renders
            // rectangular for one frame. When called construction-time (bounds == .zero),
            // the persistent pill flag picks it up on the first layoutSubviews pass.
            if bounds.height > 0 {
                round(corners: maskedCorners, radius: bounds.height / 2)
            }
        }
        return self
    }

    /// Deprecated. The `animated` parameter is no longer supported — it used to
    /// schedule a one-shot animation on the next layout pass, but that interacts
    /// poorly with the layout cycle and never re-fires on bounds changes. Wrap
    /// the call in `UIView.animate { ... }` if you want animated rounding.
    @available(*, deprecated, message: "The 'animated' parameter is no longer supported. Wrap the call in UIView.animate { view.setAsRoundedView(...) } for animated rounding.")
    @discardableResult public func setAsRoundedView(using maskedCorners: CACornerMask = .all, radius: CGFloat? = nil, animated: Bool) -> Self {
        setAsRoundedView(using: maskedCorners, radius: radius)
    }
}
