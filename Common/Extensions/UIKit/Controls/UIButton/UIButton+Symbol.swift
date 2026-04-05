//
//  UIButton+Symbol.swift
//

import UIKit

extension UIButton {
    
    /// Sets a SF Symbol image for the button.
    /// - Parameters:
    ///   - named: The name of the symbol.
    ///   - configuration: The symbol configuration.
    ///   - state: The control state. Defaults to `.normal`.
    ///   - insets: Content insets. Defaults to `.zero`.
    ///   - semanticContentAttribute: The semantic content attribute. Defaults to `.forceLeftToRight`.
    @discardableResult public func symbol(_ named: String, configuration: UIImage.SymbolConfiguration? = nil, for state: State = .normal, insets: NSDirectionalEdgeInsets = .zero, semanticContentAttribute: UISemanticContentAttribute = .forceLeftToRight) -> Self {
        with { $0.image(.symbol(named, configuration: configuration), for: state, insets: insets, semanticContentAttribute: semanticContentAttribute) }
    }
}
