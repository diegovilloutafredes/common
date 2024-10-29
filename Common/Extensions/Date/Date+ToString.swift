//
//  Date+ToString.swift
//

import Foundation

// MARK: - To String
extension Date {
    public func toString(with format: String) -> String {
        DateFormatter()
            .with {
                $0.dateFormat = format
                $0.locale = .init(identifier: .DefaultValues.Locale.esCL)
            }.string(from: self)
    }
}
