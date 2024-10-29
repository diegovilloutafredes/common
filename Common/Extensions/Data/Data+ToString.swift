//
//  Data+ToString.swift
//

import Foundation

extension Data {
    public func toString(using encoding: String.Encoding = .utf8) -> String? { .init(data: self, encoding: encoding) }
}
