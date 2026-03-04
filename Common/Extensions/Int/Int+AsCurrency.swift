//
//  Int+AsCurrency.swift
//

extension Int {
    
    /// Formats the integer as a currency string using the Chilean locale (es_CL).
    /// Returns the decimal formatted string with a '$' prefix if currency formatting fails.
    public var asCurrency: String {
        NumberFormatter()
            .with {
                $0.locale = .init(identifier: .DefaultValues.Locale.esCL)
                $0.numberStyle = .currency
            }
            .string(from: .init(value: self)) ?? "$\(asDecimalNumber)"
    }
}
