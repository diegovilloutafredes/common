//
//  Uppercaseable.swift
//

// MARK: - Uppercaseable
// MARK: - Uppercaseable
/// A protocol for types that can provide uppercased versions of their string representation.
public protocol Uppercaseable {
    
    /// An uppercased version of the string.
    var uppercased: String { get }
    
    /// A version of the string with only the first letter uppercased.
    var uppercasingFirstLetter: String { get }
}

extension Uppercaseable where Self: RawRepresentable, RawValue == String {
    public var uppercased: String { rawValue.localizedUppercase }
    public var uppercasingFirstLetter: String { rawValue.uppercasingFirstLetter }
}

extension Uppercaseable where Self: Stringable {
    public var uppercased: String { asString.localizedUppercase }
    public var uppercasingFirstLetter: String { asString.uppercasingFirstLetter }
}
