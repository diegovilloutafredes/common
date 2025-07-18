//
//  Data+AsString.swift
//

import Foundation

extension Data {
    public func asString(using encoding: String.Encoding = .utf8) -> String? { .init(data: self, encoding: encoding) }
}
