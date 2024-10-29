//
//  URL+AddQueryItem.swift
//

import Foundation

extension URL {
    public func add(queryItem: URLQueryItem) -> URL {
        guard var components else { return absoluteURL }
        var queryItems = components.queryItems ??  []
        queryItems.append(queryItem)
        components.queryItems = queryItems
        return components.url!
    }
}
