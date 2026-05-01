//
//  Int+AsDecimalNumber.swift
//

extension Int {

    private static let _decimalFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = .init(identifier: .DefaultValues.Locale.esCL)
        f.numberStyle = .decimal
        return f
    }()

    /// Formats the integer as a decimal number string using the Chilean locale (es_CL).
    public var asDecimalNumber: String {
        Self._decimalFormatter.string(from: .init(value: self)) ?? asString
    }
}
