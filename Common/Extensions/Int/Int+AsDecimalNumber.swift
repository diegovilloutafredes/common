//
//  Int+AsDecimalNumber.swift
//

extension Int {
    
    /// Formats the integer as a decimal number string using the Chilean locale (es_CL).
    public var asDecimalNumber: String {
        NumberFormatter()
            .with {
                $0.locale = .init(identifier: .DefaultValues.Locale.esCL)
                $0.numberStyle = .decimal
            }
            .string(from: .init(value: self)) ?? asString
    }
}
