//
//  Capitalizable.swift
//

// MARK: - Capitalizable
public protocol Capitalizable {
    var capitalized: String { get }
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
