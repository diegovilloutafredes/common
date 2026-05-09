//
//  String+RUTUtilities.swift
//

import Foundation

// MARK: - RUT Utilities
extension String {

    /// Validates if the string is a valid Chilean RUT.
    /// Accepts both formatted ("12.345.678-9") and unformatted ("123456789") inputs.
    public var isRUT: Bool {
        let rut = removeRUTFormat().uppercased()
        guard rut.count >= 8 && rut.count <= 10 else { return false }
        guard Self._rutPredicate.evaluate(with: rut) else { return false }
        let components = rut.rutComponents
        return components.verifyingDigit == rut.calculatedVerifyingDigit(for: components.number)
    }

    /// Formats the string as a Chilean RUT (e.g., "12.345.678-9").
    /// Accepts both formatted and unformatted inputs.
    /// - Parameter onlyIfValid: Only formats if the string is a valid RUT. Defaults to `true`.
    /// - Returns: The formatted RUT string, or `self` if validation fails or formatting is not possible.
    @discardableResult public func formatAsRUT(onlyIfValid: Bool = true) -> Self {
        let stripped = removeRUTFormat()
        guard onlyIfValid ? stripped.isRUT : true else { return self }
        let components = stripped.rutComponents
        guard let formattedNumber = components.number.asInt?.asDecimalNumber else { return self }
        return "\(formattedNumber)-\(components.verifyingDigit.uppercased())"
    }

    /// Removes RUT formatting characters (dots and hyphens).
    /// - Returns: The string with "." and "-" removed.
    @discardableResult public func removeRUTFormat() -> Self {
        with { $0 = $0.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "") }
    }
}

// MARK: - Private
private extension String {

    static let _rutPredicate = NSPredicate(
        format: "SELF MATCHES %@",
        "^(\\d{1,3}(\\.?\\d{3}){2})\\-?([\\dkK])$"
    )

    /// Returns the number and verifying digit components of a stripped RUT string.
    var rutComponents: (number: String, verifyingDigit: String) {
        guard count > 1 else { return (.empty, .empty) }
        return (String(dropLast()), String(last!))
    }

    /// Computes the expected verifying digit for a RUT number using the Módulo 11 algorithm.
    func calculatedVerifyingDigit(for number: String) -> String {
        var accumulated = 0
        var multiplier = 2
        for char in number.reversed() {
            guard let digit = char.wholeNumberValue else { continue }
            accumulated += digit * multiplier
            multiplier = multiplier == 7 ? 2 : multiplier + 1
        }
        switch 11 - (accumulated % 11) {
        case 10: return "K"
        case 11: return .zero  // sum % 11 == 0 → verifying digit is "0"
        case let d: return String(d)
        }
    }
}
