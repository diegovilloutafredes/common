//
//  Data+Decoded.swift
//

import Foundation

extension Data {
    
    /// Decodes the data into a `Decodable` object.
    /// - Returns: The decoded object, or `nil` if decoding fails.
    public func decoded<T: Decodable>() -> T? {
        try? JSONDecoder().decode(T.self, from: self)
    }
}
