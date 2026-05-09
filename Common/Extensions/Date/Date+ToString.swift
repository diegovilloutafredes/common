//
//  Date+ToString.swift
//

import Foundation

// MARK: - To String
extension Date {

    nonisolated(unsafe) private static let _formatterCache = NSCache<NSString, DateFormatter>()

    /// Converts the date to a string using the specified format.
    /// - Parameter format: The date format string (e.g., "yyyy-MM-dd").
    /// - Returns: The formatted date string (using es_CL locale by default).
    public func toString(with format: String) -> String {
        let key = format as NSString
        if let cached = Date._formatterCache.object(forKey: key) {
            return cached.string(from: self)
        }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = .init(identifier: .DefaultValues.Locale.esCL)
        Date._formatterCache.setObject(formatter, forKey: key)
        return formatter.string(from: self)
    }
}
