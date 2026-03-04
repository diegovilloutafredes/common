//
//  NSRange+CustomInit.swift
//

import Foundation

extension NSRange {
    
    /// Initializes an NSRange from a Swift String range.
    /// - Parameters:
    ///   - range: The Swift String range.
    ///   - originalText: The original string used for calculation.
    public init(range: Range<String.Index>, originalText: String) {
        self.init(
            location: range.lowerBound.utf16Offset(in: originalText),
            length: range.upperBound.utf16Offset(in: originalText) - range.lowerBound.utf16Offset(in: originalText)
        )
    }
}
