//
//  String+AsDate.swift
//

import Foundation

extension String {

    nonisolated(unsafe) private static let _formatterCache = NSCache<NSString, DateFormatter>()

    /// Converts the string to a Date using the specified format and locale.
    /// - Parameters:
    ///   - format: The date format string.
    ///   - locale: The locale to use. Defaults to `es_CL`.
    /// - Returns: The date object, or `nil` if conversion fails.
    public func asDate(with format: String, locale: Locale = .init(identifier: .DefaultValues.Locale.esCL)) -> Date? {
        let key = "\(format)|\(locale.identifier)" as NSString
        if let cached = String._formatterCache.object(forKey: key) {
            return cached.date(from: self)
        }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        String._formatterCache.setObject(formatter, forKey: key)
        return formatter.date(from: self)
    }
}
