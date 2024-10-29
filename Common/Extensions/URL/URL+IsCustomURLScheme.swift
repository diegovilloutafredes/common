//
//  URL+IsCustomURLScheme.swift
//

import Foundation

extension URL {
    public func isCustomURLScheme() -> Bool {
        let webURLPrefixes = ["http://", "https://", "about:"]
        let lowercasedURLAsString = absoluteString.lowercased()

        guard webURLPrefixes.filter({ lowercasedURLAsString.hasPrefix($0) }).isEmpty else { return false }

        return lowercasedURLAsString.contains(":")
    }
}
