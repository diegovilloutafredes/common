//
//  UIButton+Image.swift
//

import UIKit

extension UIButton {
    @discardableResult public func image(_ image: UIImage?, for state: State = .normal, insets: NSDirectionalEdgeInsets = .zero, semanticContentAttribute: UISemanticContentAttribute = .forceLeftToRight) -> Self {
        with {
            $0.semanticContentAttribute(semanticContentAttribute)
            setImage(image, for: state)
            configuration?.contentInsets = insets
        }
    }
}
