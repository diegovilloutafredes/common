//
//  JSONDecoder+KeyDecodingStrategy.swift
//

import Foundation

extension JSONDecoder {
    @discardableResult public func keyDecodingStrategy(_ keyDecodingStrategy: KeyDecodingStrategy) -> Self {
        with { $0.keyDecodingStrategy = keyDecodingStrategy }
    }
}
