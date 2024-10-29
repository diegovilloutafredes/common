//
//  String+Hyphened.swift
//

import Foundation

// MARK: - Hyphened
extension String {
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
