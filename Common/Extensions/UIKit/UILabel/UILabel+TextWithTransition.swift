//
//  UILabel+TextWithTransition.swift
//

import UIKit

extension UILabel {
    
    /// Sets the text with a transition animation.
    /// - Parameters:
    ///   - text: The text to set.
    ///   - options: Animation options. Defaults to cross dissolve with ease in/out.
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
