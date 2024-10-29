//
//  UIView+SetAlpha.swift
//

import UIKit

// MARK: - Set Alpha
extension UIView {
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
