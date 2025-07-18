//
//  Int+AsDecimalNumber.swift
//

extension Int {
    public var asDecimalNumber: String {
        NumberFormatter()
            .with {
                $0.locale = .init(identifier: .DefaultValues.Locale.esCL)
                $0.numberStyle = .decimal
            }
            .string(from: .init(value: self)) ?? asString
    }
}
