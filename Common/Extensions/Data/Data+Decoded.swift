//
//  Data+Decoded.swift
//

import Foundation

extension Data {
    public func decoded<T: Decodable>() -> T? {
        try? JSONDecoder().decode(T.self, from: self)
    }
}
