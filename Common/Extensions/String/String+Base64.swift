//
//  String+Base64.swift
//

import Foundation

extension String {
    public var decodedFromBase64: String? { Data(base64Encoded: self)?.asString() }
}

extension String {
    public var encodedAsBase64: String { asData.base64EncodedString() }
}
