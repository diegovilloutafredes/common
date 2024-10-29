//
//  URL+RemoveQueryItem.swift
//

import Foundation

extension URL {
    public func remove(queryItem: URLQueryItem) -> URL {
        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }
        let queryItems = urlComponents.queryItems ??  []
        urlComponents.queryItems = queryItems.filter { $0 != queryItem }
        return urlComponents.url!
    }
}
