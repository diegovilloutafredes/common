//
//  Date+AsMilliseconds.swift
//

import Foundation

extension Date {
    
    /// Returns the current date as milliseconds since 1970.
    public static var asMilliseconds: Int64 { .init((Date().timeIntervalSince1970 * 1000.0).rounded()) }
}
