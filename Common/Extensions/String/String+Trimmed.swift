//
//  String+Trimmed.swift
//

import Foundation

extension String {

    /// Returns the string with leading and trailing whitespace and newlines removed.
    public var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
