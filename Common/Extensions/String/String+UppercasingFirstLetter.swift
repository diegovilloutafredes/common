//
//  String+UppercasingFirstLetter.swift
//

import Foundation

extension String {
    
    /// Returns the string with the first letter capitalized (using localized uppercase).
    public var uppercasingFirstLetter: String { prefix(1).localizedUppercase + dropFirst() }
}
