//
//  URL+GetValueFromQueryItem.swift
//

import Foundation

extension URL {
    
    /// Retrieves the value of a specific query parameter.
    /// - Parameter key: The name of the query parameter.
    /// - Returns: The value of the parameter, or `nil` if not found.
    public func getValueFromQueryItem(_ key: String) -> String? { queryItems?.first { $0.name == key }?.value }
}
