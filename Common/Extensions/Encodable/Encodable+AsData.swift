//
//  Encodable+AsData.swift
//

import Foundation

extension Encodable {
    
    /// Encodes the object into Data using the specified encoder.
    /// - Parameter encoder: The JSONEncoder to use. Defaults to `JSONEncoder()`.
    /// - Returns: The encoded data, or `nil` if encoding fails.
    public func asData(encoder: JSONEncoder = .init()) -> Data? { try? encoder.encode(self) }
}
