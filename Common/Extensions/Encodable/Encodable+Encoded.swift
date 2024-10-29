//
//  Encodable+Encoded.swift
//

import Foundation

extension Encodable {
    public var encoded: Data? { try? JSONEncoder().encode(self) }
}
