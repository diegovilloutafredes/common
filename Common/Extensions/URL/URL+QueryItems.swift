//
//  URL+QueryItems.swift
//

import Foundation

extension URL {
    
    /// Returns the query items from the URL components.
    public var queryItems: [URLQueryItem]? { components?.queryItems }
}
