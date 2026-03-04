//
//  String+AsData.swift
//

import Foundation

extension String {
    
    /// Converts the string to Data using UTF-8 encoding.
    public var asData: Data { .init(utf8) }
}
