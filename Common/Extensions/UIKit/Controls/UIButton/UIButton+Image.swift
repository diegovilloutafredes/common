//
//  UIButton+Image.swift
//

import UIKit

extension UIButton {
    
    /// Sets the image for a specific state and optional configuration.
    /// - Parameters:
    ///   - image: The image to set.
    ///   - state: The control state. Defaults to `.normal`.
    ///   - insets: Content insets to apply to configuration. Defaults to `.zero`.
    ///   - semanticContentAttribute: The semantic content attribute. Defaults to `.forceLeftToRight`.
    @discardableResult public func image(_ image: UIImage?, for state: State = .normal, insets: NSDirectionalEdgeInsets = .zero, semanticContentAttribute: UISemanticContentAttribute = .forceLeftToRight) -> Self {
        with {
            $0.semanticContentAttribute(semanticContentAttribute)
            setImage(image, for: state)
            configuration?.contentInsets = insets
        }
    }
}
