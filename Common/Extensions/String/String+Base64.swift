//
//  String+Base64.swift
//

import Foundation

extension String {
    
    /// Decodes the string from Base64.
    public var decodedFromBase64: String? { Data(base64Encoded: self)?.asString() }
}

extension String {
    
    /// Encodes the string to Base64.
    public var encodedAsBase64: String { asData.base64EncodedString() }
}
