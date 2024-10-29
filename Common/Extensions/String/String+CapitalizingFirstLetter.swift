//
//  String+CapitalizingFirstLetter.swift
//

import Foundation

extension String {
    public var capitalizingFirstLetter: String { 
        split(separator: " ")
        .map { $0.prefix(1).uppercased() + $0.lowercased().dropFirst() }
        .joined(separator: " ")
    }
}
