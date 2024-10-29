//
//  CustomStringConvertible+Description.swift
//

import Foundation

// MARK: - CustomStringConvertible
extension CustomStringConvertible {
    public var description: String {
        Mirror(reflecting: self)
            .children
            .map { "\($0.label ?? "No label"): \($0.value)" }
            .joined(separator: "\n")
    }
}
