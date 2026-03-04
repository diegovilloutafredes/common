//
//  NSMutableAttributedString+ApplyAttributes.swift
//

import Foundation

extension NSMutableAttributedString {
    
    /// Applies an attribute to a specific range.
    /// - Parameters:
    ///   - attribute: The attribute (key-value pair) to apply.
    ///   - range: The range to apply the attribute to.
    /// - Returns: Self (chainable).
    @discardableResult public func apply(_ attribute: (key: NSAttributedString.Key, value: Any), range: NSRange) -> Self {
        with { $0.addAttribute(attribute.key, value: attribute.value, range: range) }
    }
}

extension NSMutableAttributedString {
    
    /// Applies an attribute to a specific range using String.Index range.
    /// - Parameters:
    ///   - attribute: The attribute (key-value pair) to apply.
    ///   - range: The range to apply the attribute to.
    /// - Returns: Self (chainable).
    @discardableResult public func apply(_ attribute: (key: NSAttributedString.Key, value: Any), range: Range<String.Index>) -> Self {
        apply(
            attribute,
            range: .init(range: range, originalText: string)
        )
    }
}

extension NSMutableAttributedString {
    
    /// Applies a dictionary of attributes to a specific range.
    /// - Parameters:
    ///   - attributes: The dictionary of attributes to apply.
    ///   - range: The range to apply the attributes to.
    /// - Returns: Self (chainable).
    @discardableResult public func apply(_ attributes: [NSAttributedString.Key: Any], range: NSRange) -> Self {
        with { $0.addAttributes(attributes, range: range) }
    }
}

extension NSMutableAttributedString {
    
    /// Applies a dictionary of attributes to a specific range using String.Index range.
    /// - Parameters:
    ///   - attributes: The dictionary of attributes to apply.
    ///   - range: The range to apply the attributes to.
    /// - Returns: Self (chainable).
    @discardableResult public func apply(_ attributes: [NSAttributedString.Key: Any], range: Range<String.Index>) -> Self {
        apply(
            attributes,
            range: .init(range: range, originalText: string)
        )
    }
}
