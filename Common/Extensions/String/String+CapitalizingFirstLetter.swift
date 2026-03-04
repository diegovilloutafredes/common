//
//  String+CapitalizingFirstLetter.swift
//

import Foundation

extension String {
    
    /// Capitalizes the first letter of each word in the string.
    /// Words are assumed to be separated by spaces.
    public var capitalizingFirstLetter: String { 
        split(separator: " ")
        .map { $0.prefix(1).uppercased() + $0.lowercased().dropFirst() }
        .joined(separator: " ")
    }
}
