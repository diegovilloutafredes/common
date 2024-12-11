//
//  String+AsDecimalNumber.swift
//

import Foundation

// MARK: - Add Decimal Dots
extension String {
    public var asDecimalNumber: String? {
        let numberFormatter = NumberFormatter()
            .with {
                $0.numberStyle = .decimal
                $0.locale = .init(identifier: .DefaultValues.Locale.esCL)
            }
        guard let asNumber = numberFormatter.number(from: self) else { return nil }
        return numberFormatter.string(from: asNumber)
    }
}
