//
//  UILabel+TextWithTransition.swift
//

import UIKit

extension UILabel {
    @discardableResult public func textWithTransition(
        _ text: String,
        options: UIView.AnimationOptions = [
            .curveEaseInOut,
            .transitionCrossDissolve
        ]
    ) -> Self {
        with { label in
            UIView.transition(
                with: label,
                duration: .DefaultValues.animationDuration,
                options: options,
                animations: { label.text(text) }
            )
        }
    }
}
