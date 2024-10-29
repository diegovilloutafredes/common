//
//  String+Base64.swift
//

import Foundation

extension String {
    public func decodeFromBase64() -> String? { Data(base64Encoded: self)?.toString() }
}

extension String {
    public func encodeAsBase64() -> String { toData().base64EncodedString() }
}
