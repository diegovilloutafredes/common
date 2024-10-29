//
//  Date+AsMilliseconds.swift
//

import Foundation

extension Date {
    static var asMilliseconds: Int64 { .init((Date().timeIntervalSince1970 * 1000.0).rounded()) }
}
