//
//  Capitalizable.swift
//

// MARK: - Capitalizable
// MARK: - Capitalizable
/// A protocol for types that can provide capitalized versions of their string representation.
public protocol Capitalizable {
    
    /// A capitalized version of the string.
    var capitalized: String { get }
    
    /// A version of the string with only the first letter capitalized.
    var capitalizingFirstLetter: String { get }
}

extension Capitalizable where Self: RawRepresentable, RawValue == String {
    public var capitalized: String { rawValue.localizedCapitalized }
    public var capitalizingFirstLetter: String { rawValue.capitalizingFirstLetter }
}

extension Capitalizable where Self: RawRepresentable & Stringable, RawValue == String {
    public var capitalized: String { asString.localizedCapitalized }
    public var capitalizingFirstLetter: String { asString.capitalizingFirstLetter }
}
