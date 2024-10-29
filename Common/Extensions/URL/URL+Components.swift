//
//  URL+Components.swift
//

import Foundation

extension URL {
    var components: URLComponents? { .init(string: absoluteString) }
}
