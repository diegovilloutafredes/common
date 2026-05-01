//
//  Int+AsCurrency.swift
//

extension Int {

    private static let _currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = .init(identifier: .DefaultValues.Locale.esCL)
        f.numberStyle = .currency
        return f
    }()

    /// Formats the integer as a currency string using the Chilean locale (es_CL).
    /// Returns the decimal formatted string with a '$' prefix if currency formatting fails.
    public var asCurrency: String {
        Self._currencyFormatter.string(from: .init(value: self)) ?? "$\(asDecimalNumber)"
    }
}
