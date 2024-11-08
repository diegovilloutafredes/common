//
//  UIButton+Symbol.swift
//

import UIKit

extension UIButton {
    @discardableResult public func symbol(_ named: String, configuration: UIImage.SymbolConfiguration? = nil, for state: State = .normal, insets: NSDirectionalEdgeInsets = .zero, semanticContentAttribute: UISemanticContentAttribute = .forceLeftToRight) -> Self {
        with { $0.image(.symbol(named, configuration: configuration), for: state, insets: insets, semanticContentAttribute: semanticContentAttribute) }
    }
}
