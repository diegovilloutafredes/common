//
//  UIView+ApplyBlurredForeground.swift
//

import UIKit

extension UIView {
    @discardableResult public func applyBlurredForeground(with style: UIBlurEffect.Style = .regular) -> Self {
        with {
            let blurEffect = UIBlurEffect(style: style)
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
                .setConstraints { $0.snap(to: $1) }

            switch $0 {
            case is UIStackView:
                ($0 as? UIStackView)?.addSubview(visualEffectView)
            default:
                $0.subviews { visualEffectView }
            }

            $0.bringSubviewToFront(visualEffectView)
        }
    }
}
