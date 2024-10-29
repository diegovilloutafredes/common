//
//  String+ToDate.swift
//

import Foundation

// MARK: - To Date
extension String {
    public func toDate(with format: String, language: String = .DefaultValues.Locale.esCL) -> Date? {
        DateFormatter()
            .with {
                $0.dateFormat = format
                $0.locale = .init(identifier: language)
            }.date(from: self)
    }
}
