//
//  String+AsDataDecodedFromBase64.swift
//

import Foundation

extension String {
    
    /// Decodes the string from Base64 to Data.
    /// - Returns: The decoded data, or `nil` if the string is not valid Base64.
    public var asDataDecodedFromBase64: Data? { .init(base64Encoded: self) }
}
