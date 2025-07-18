//
//  String+AsDate.swift
//

import Foundation

extension String {
    public func asDate(with format: String, locale: Locale = .init(identifier: .DefaultValues.Locale.esCL)) -> Date? {
        DateFormatter()
            .with {
                $0.dateFormat = format
                $0.locale = locale
            }
            .date(from: self)
    }
}
