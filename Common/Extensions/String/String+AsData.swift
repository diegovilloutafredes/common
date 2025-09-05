//
//  String+AsData.swift
//

import Foundation

extension String {
    public var asData: Data { .init(utf8) }
}

extension String {
    public var asDataDecodedFromBase64: Data? { .init(base64Encoded: self) }
}
