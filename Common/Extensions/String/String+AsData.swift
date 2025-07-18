//
//  String+AsData.swift
//

import Foundation

extension String {
    public var asData: Data { .init(utf8) }
}
