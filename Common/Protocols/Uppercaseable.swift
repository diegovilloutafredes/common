//
//  Uppercaseable.swift
//

// MARK: - Uppercaseable
public protocol Uppercaseable {
    var uppercased: String { get }
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
