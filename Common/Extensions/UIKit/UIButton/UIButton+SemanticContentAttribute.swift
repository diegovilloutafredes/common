//
//  UIButton+SemanticContentAttribute.swift
//

import UIKit

extension UIButton {
    
    /// Sets the semantic content attribute and returns self (chainable).
    /// - Parameter semanticContentAttribute: The attribute to set.
    @discardableResult public func semanticContentAttribute(_ semanticContentAttribute: UISemanticContentAttribute) -> Self {
        with { $0.semanticContentAttribute = semanticContentAttribute }
    }
}
