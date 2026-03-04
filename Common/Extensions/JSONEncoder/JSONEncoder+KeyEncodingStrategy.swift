//
//  JSONEncoder+KeyEncodingStrategy.swift
//

import Foundation

extension JSONEncoder {
    
    /// Sets the key encoding strategy and returns the encoder.
    /// - Parameter keyEncodingStrategy: The key encoding strategy to set.
    /// - Returns: The modified `JSONEncoder`.
    @discardableResult public func keyEncodingStrategy(_ keyEncodingStrategy: KeyEncodingStrategy) -> Self {
        with { $0.keyEncodingStrategy = keyEncodingStrategy }
    }
}
