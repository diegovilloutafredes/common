//
//  Encodable+AsJsonObject.swift
//

import Foundation

extension Encodable {
    public func asJsonObject(encoder: JSONEncoder = .init().keyEncodingStrategy(.convertToSnakeCase)) -> [String: Any]? {
        guard let data = asData(encoder: encoder) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}
