//
//  String+ToData.swift
//

import Foundation

extension String {
    public func toData() -> Data { .init(utf8) }
}
