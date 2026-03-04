//
//  Date+EpochTime.swift
//

import Foundation

// MARK: - Epoch Time
// MARK: - Epoch Time
extension Date {
    
    /// Returns the current epoch time.
    public static var epochTime: Int64 { .init(Date().timeIntervalSince1970) }
}
