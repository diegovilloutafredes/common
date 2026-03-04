//
//  URL+IsCustomURLScheme.swift
//

import Foundation

extension URL {
    
    /// Checks if the URL has a custom scheme (not http, https, or about).
    /// - Returns: `true` if it uses a custom scheme, `false` otherwise.
    public func isCustomURLScheme() -> Bool {
        let webURLPrefixes = ["http://", "https://", "about:"]
        let lowercasedURLAsString = absoluteString.lowercased()
        guard webURLPrefixes.filter({ lowercasedURLAsString.hasPrefix($0) }).isEmpty else { return false }
        return lowercasedURLAsString.contains(":")
    }
}
