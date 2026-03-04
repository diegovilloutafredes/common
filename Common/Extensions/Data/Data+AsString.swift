//
//  Data+AsString.swift
//

import Foundation

extension Data {
    
    /// Converts the data to a string using the specified encoding.
    /// - Parameter encoding: The encoding to use. Defaults to `.utf8`.
    /// - Returns: The string representation of the data, or `nil` if conversion fails.
    public func asString(using encoding: String.Encoding = .utf8) -> String? { .init(data: self, encoding: encoding) }
}
