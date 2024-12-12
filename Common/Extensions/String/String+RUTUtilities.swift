//
//  String+RUTUtilities.swift
//

import Foundation

// MARK: - RUT Utilities
extension String {
    public var isRUT: Bool {
        removeRUTFormat()

        let rut = uppercased()

        guard rut.count >= 8 || rut.count <= 10 else { return false }

        let rutRegex = "^(\\d{1,3}(\\.?\\d{3}){2})\\-?([\\dkK])$"
        let rutTest = NSPredicate(format: "SELF MATCHES %@", rutRegex)

        if !rutTest.evaluate(with: rut) { return false }

        let components = getRUTComponents()
        let number = components.number
        let verifyingDigit = components.verifyingDigit.uppercased()
        let calculatedVD = calculateVerifyingDigit(of: number)

        return verifyingDigit == calculatedVD
    }
}

extension String {
    @discardableResult public func formatAsRUT(onlyIfValid: Bool = true) -> Self {
        removeRUTFormat()
            .with {
                guard onlyIfValid ? $0.isRUT : true else { return }

                let components = getRUTComponents()
                let number = components.number
                let verifyingDigit = components.verifyingDigit

                guard let formattedNumber = number.asDecimalNumber else { return }

                $0 = "\(formattedNumber)-\(verifyingDigit)"
            }
    }
}

extension String {
    @discardableResult public func removeRUTFormat() -> Self {
        with { $0 = $0.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "") }
    }
}

// MARK: - Convenience
extension String {
    private func calculateVerifyingDigit(of rut: String) -> String? {
        let asArray = rut.map { String($0) }
        var acumulated = 0
        var multiplier = 2

        stride(from: rut.count - 1, through: .zero, by: -1)
            .forEach {
                guard let currentDigit = asArray[$0].asInt else { return }
                acumulated += currentDigit * multiplier
                if multiplier == 7 { multiplier = 1 }
                multiplier += 1
            }

        let remainder = acumulated % 11
        let difference = 11 - remainder

        var verifyingDigit: String {
            switch difference {
            case 10: "K"
            case .zero...9: difference.asString
            default: .zero
            }
        }

        return verifyingDigit
    }
}

extension String {
    private func getRUTComponents() -> (number: String, verifyingDigit: String) {
        guard count > 1 else { return (.empty, .empty) }

        removeRUTFormat()
        let number = String(dropLast())
        let verifyingDigit = String(last!)

        return (number, verifyingDigit)
    }
}
