//
//  String+AsDate.swift
//

import Foundation

extension String {

    nonisolated(unsafe) private static let _formatterCache = NSCache<NSString, DateFormatter>()

    /// Converts the string to a Date using the specified format and locale.
    ///
    /// Parsing uses the current time zone. On a day whose local midnight doesn't exist (a DST
    /// transition at midnight), a date-only string still parses, to the first valid instant of
    /// that day. Input that doesn't match the format returns nil.
    /// - Parameters:
    ///   - format: The date format string.
    ///   - locale: The locale to use. Defaults to `es_CL`.
    /// - Returns: The date object, or `nil` if conversion fails.
    public func asDate(with format: String, locale: Locale = .init(identifier: .DefaultValues.Locale.esCL)) -> Date? {
        let strict = String.formatter(format: format, locale: locale, isLenient: false)
        if let date = strict.date(from: self) { return date }
        // A strict parse also fails when the format implies a time the zone skips. Retry leniently,
        // but accept only a date that formats back to exactly this string: leniency alone would roll
        // invalid input over into some other date instead of returning nil.
        guard
            let date = String.formatter(format: format, locale: locale, isLenient: true).date(from: self),
            strict.string(from: date) == self
        else { return nil }
        return date
    }

    /// Cached per format, locale and leniency; configured only at creation, since cached formatters
    /// are shared across threads.
    private static func formatter(format: String, locale: Locale, isLenient: Bool) -> DateFormatter {
        let key = "\(format)|\(locale.identifier)\(isLenient ? "|lenient" : "")" as NSString
        if let cached = _formatterCache.object(forKey: key) { return cached }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        formatter.isLenient = isLenient
        _formatterCache.setObject(formatter, forKey: key)
        return formatter
    }
}
