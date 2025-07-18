//
//  Encodable+AsString.swift
//

import Foundation

extension Encodable {
    public func asString(encoder: JSONEncoder = .init()) -> String? {
        guard let data = asData(encoder: encoder) else { return nil }
        return .init(data: data, encoding: .utf8)
    }
}
