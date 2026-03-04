//
//  String+Hyphened.swift
//

import Foundation

// MARK: - Hyphened
// MARK: - Hyphened
extension String {
    
    /// Inserts a hyphen before the last character of the string.
    /// Useful for formatting Chilean RUTs (e.g., 123456789 -> 12345678-9).
    public var hyphened: String {
        var mutableSelf = self

        guard
            mutableSelf.isNotEmpty,
            mutableSelf.count > 1
        else { return self }

        let indexToInsertHyphen = mutableSelf.index(before: mutableSelf.endIndex)
        mutableSelf.insert("-", at: indexToInsertHyphen)

        return mutableSelf
    }
}
