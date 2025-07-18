//
//  Int+AsCurrency.swift
//

extension Int {
    public var asCurrency: String {
        NumberFormatter()
            .with {
                $0.locale = .init(identifier: .DefaultValues.Locale.esCL)
                $0.numberStyle = .currency
            }
            .string(from: .init(value: self)) ?? "$\(asDecimalNumber)"
    }
}
