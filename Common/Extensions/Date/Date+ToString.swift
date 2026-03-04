//
//  Date+ToString.swift
//

import Foundation

// MARK: - To String
// MARK: - To String
extension Date {
    
    /// Converts the date to a string using the specified format.
    /// - Parameter format: The date format string (e.g., "yyyy-MM-dd").
    /// - Returns: The formatted date string (using es_CL locale by default).
    public func toString(with format: String) -> String {
        DateFormatter()
            .with {
                $0.dateFormat = format
                $0.locale = .init(identifier: .DefaultValues.Locale.esCL)
            }.string(from: self)
    }
}
