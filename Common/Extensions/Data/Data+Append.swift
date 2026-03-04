//
//  Data+Append.swift
//

import Foundation

extension Data {
    
    /// Appends a string to the data using the specified encoding.
    /// - Parameters:
    ///   - string: The string to append.
    ///   - encoding: The encoding to use. Defaults to `.utf8`.
    mutating public func append(_ string: String, encoding: String.Encoding = .utf8) {
        guard let data = string.data(using: encoding) else { return }
        append(data)
    }
}
