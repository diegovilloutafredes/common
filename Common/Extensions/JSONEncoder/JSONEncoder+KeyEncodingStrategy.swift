//
//  JSONEncoder+KeyEncodingStrategy.swift
//

import Foundation

extension JSONEncoder {
    @discardableResult public func keyEncodingStrategy(_ keyEncodingStrategy: KeyEncodingStrategy) -> Self {
        with { $0.keyEncodingStrategy = keyEncodingStrategy }
    }
}
