//
//  URL+AddQueryItem.swift
//

import Foundation

extension URL {
    
    /// Adds a query item to the URL.
    /// - Parameter queryItem: The query item to add.
    /// - Returns: A new URL with the added query item, or the original URL if operation fails.
    public func add(queryItem: URLQueryItem) -> URL {
        guard var components else { return absoluteURL }
        var queryItems = components.queryItems ??  []
        queryItems.append(queryItem)
        components.queryItems = queryItems
        return components.url!
    }
}
