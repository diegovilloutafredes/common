//
//  String+AsDate.swift
//

import Foundation

extension String {
    
    /// Converts the string to a Date using the specified format and locale.
    /// - Parameters:
    ///   - format: The date format string.
    ///   - locale: The locale to use. Defaults to `es_CL`.
    /// - Returns: The date object, or `nil` if conversion fails.
    public func asDate(with format: String, locale: Locale = .init(identifier: .DefaultValues.Locale.esCL)) -> Date? {
        DateFormatter()
            .with {
                $0.dateFormat = format
                $0.locale = locale
            }
            .date(from: self)
    }
}
