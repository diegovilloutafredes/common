//
//  NSRange+CustomInit.swift
//

import Foundation

extension NSRange {
    public init(range: Range<String.Index>, originalText: String) {
        self.init(
            location: range.lowerBound.utf16Offset(in: originalText),
            length: range.upperBound.utf16Offset(in: originalText) - range.lowerBound.utf16Offset(in: originalText)
        )
    }
}
