//
//  UIView+SetAlpha.swift
//

import UIKit

// MARK: - Set Alpha
extension UIView {
    
    /// Sets the alpha value with optional animation.
    /// - Parameters:
    ///   - value: The alpha value (0.0 to 1.0).
    ///   - animated: Whether to animate. Defaults to `true`.
    public func set(alpha value: CGFloat, animated: Bool = true) {
        guard alpha != value else { return }

        guard animated else {
            alpha = value
            return
        }

        dispatchOnMain { [weak self] in guard let self else { return }
            UIView.animate(withDuration: .DefaultValues.animationDuration) { self.alpha = value }
        }
    }
}
