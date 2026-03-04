//
//  JSONDecoder+KeyDecodingStrategy.swift
//

import Foundation

extension JSONDecoder {
    
    /// Sets the key decoding strategy and returns the decoder.
    /// - Parameter keyDecodingStrategy: The key decoding strategy to set.
    /// - Returns: The modified `JSONDecoder`.
    @discardableResult public func keyDecodingStrategy(_ keyDecodingStrategy: KeyDecodingStrategy) -> Self {
        with { $0.keyDecodingStrategy = keyDecodingStrategy }
    }
}
