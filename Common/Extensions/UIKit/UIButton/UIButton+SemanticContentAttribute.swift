//
//  UIButton+SemanticContentAttribute.swift
//

import UIKit

extension UIButton {
    @discardableResult public func semanticContentAttribute(_ semanticContentAttribute: UISemanticContentAttribute) -> Self {
        with { $0.semanticContentAttribute = semanticContentAttribute }
    }
}
