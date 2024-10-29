//
//  NSMutableAttributedString+ApplyAttributes.swift
//

import Foundation

extension NSMutableAttributedString {
    @discardableResult public func apply(_ attribute: (key: NSAttributedString.Key, value: Any), range: NSRange) -> NSMutableAttributedString {
        with { $0.addAttribute(attribute.key, value: attribute.value, range: range) }
    }
}

extension NSMutableAttributedString {
    @discardableResult public func apply(_ attribute: (key: NSAttributedString.Key, value: Any), range: Range<String.Index>) -> NSMutableAttributedString {
        apply(
            attribute,
            range: .init(range: range, originalText: string)
        )
    }
}

extension NSMutableAttributedString {
    @discardableResult public func apply(_ attributes: [NSAttributedString.Key: Any], range: NSRange) -> NSMutableAttributedString {
        with { $0.addAttributes(attributes, range: range) }
    }
}

extension NSMutableAttributedString {
    @discardableResult public func apply(_ attributes: [NSAttributedString.Key: Any], range: Range<String.Index>) -> NSMutableAttributedString {
        apply(
            attributes,
            range: .init(range: range, originalText: string)
        )
    }
}
