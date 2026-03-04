//
//  URL+Components.swift
//

import Foundation

extension URL {
    
    /// Returns the URLComponents of the URL.
    public var components: URLComponents? { .init(string: absoluteString) }
}
