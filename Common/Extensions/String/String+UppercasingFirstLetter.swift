//
//  String+UppercasingFirstLetter.swift
//

import Foundation

extension String {
    public var uppercasingFirstLetter: String { prefix(1).localizedUppercase + dropFirst() }
}
