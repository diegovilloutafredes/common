//
//  URL+RemoveQueryItem.swift
//

import Foundation

extension URL {
    
    /// Removes a query item from the URL.
    /// - Parameter queryItem: The query item to remove.
    /// - Returns: A new URL without the specified query item, or the original if operation fails.
    public func remove(queryItem: URLQueryItem) -> URL {
        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }
        let queryItems = urlComponents.queryItems ??  []
        urlComponents.queryItems = queryItems.filter { $0 != queryItem }
        return urlComponents.url!
    }
}
