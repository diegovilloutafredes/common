//
//  String+AsData.swift
//

import Foundation

extension String {
    
    /// Converts the string to Data using UTF-8 encoding.
    @available(*, deprecated, message: "Use Data(string.utf8). asData() is the JSON encoding.")
    public var asData: Data { .init(utf8) }
}
