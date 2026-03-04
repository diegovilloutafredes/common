//
//  Encodable+AsJsonObject.swift
//

import Foundation

extension Encodable {
    
    /// Converts the encodable object to a JSON dictionary.
    /// - Parameter encoder: The JSONEncoder to use. Defaults to `JSONEncoder()` with `.convertToSnakeCase` key encoding strategy.
    /// - Returns: A dictionary representation of the object, or `nil` if conversion fails.
    public func asJsonObject(encoder: JSONEncoder = .init().keyEncodingStrategy(.convertToSnakeCase)) -> [String: Any]? {
        guard let data = asData(encoder: encoder) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}
