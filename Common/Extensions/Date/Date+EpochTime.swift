//
//  Date+EpochTime.swift
//

import Foundation

// MARK: - Epoch Time
extension Date {
    static var epochTime: Int64 { .init(Date().timeIntervalSince1970) }
}
