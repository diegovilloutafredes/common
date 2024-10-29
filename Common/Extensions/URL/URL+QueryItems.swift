//
//  URL+QueryItems.swift
//

import Foundation

extension URL {
    public var queryItems: [URLQueryItem]? { components?.queryItems }
}
