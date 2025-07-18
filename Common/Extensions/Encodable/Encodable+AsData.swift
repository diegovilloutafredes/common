//
//  Encodable+AsData.swift
//

import Foundation

extension Encodable {
    public func asData(encoder: JSONEncoder = .init()) -> Data? { try? encoder.encode(self) }
}
