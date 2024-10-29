//
//  String+FormatAsDecimalNumber.swift
//

import Foundation

// MARK: - Add Decimal Dots
extension String {
    public func formatAsDecimalNumber() -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale(identifier: .DefaultValues.Locale.esCL)
        guard let asNumber = numberFormatter.number(from: self) else { return nil }
        return numberFormatter.string(from: asNumber)
    }
}
