//
//  URL+GetValueFromQueryItem.swift
//

import Foundation

extension URL {
    public func getValueFromQueryItem(_ key: String) -> String? { queryItems?.first { $0.name == key }?.value }
}
