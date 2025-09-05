//
//  Keyable.swift
//

// MARK: - Keyable
public protocol Keyable {
    var key: String { get }
    static var staticKey: String { get }
}

// MARK: - Default implementation
extension Keyable {
    public var key: String { .init(describing: self) }
    public static var staticKey: String { .init(describing: self) }
}

// MARK: - where Self: RawRepresentable, RawValue == String
extension Keyable where Self: RawRepresentable, RawValue == String {
    public var key: String { rawValue }
}

// MARK: - where Self: Stringable
extension Keyable where Self: Stringable {
    public var key: String { asString }
}
