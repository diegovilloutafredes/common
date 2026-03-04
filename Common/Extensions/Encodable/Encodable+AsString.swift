//
//  Encodable+AsString.swift
//

import Foundation

extension Encodable {
    
    /// Encodes the object to a String.
    /// - Parameter encoder: The JSONEncoder to use. Defaults to `JSONEncoder()`.
    /// - Returns: A string representation of the encoded object, or `nil` if encoding fails.
    public func asString(encoder: JSONEncoder = .init()) -> String? {
        guard let data = asData(encoder: encoder) else { return nil }
        return .init(data: data, encoding: .utf8)
    }
}
