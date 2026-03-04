//
//  Keyable.swift
//

// MARK: - Keyable
// MARK: - Keyable
/// A protocol for types that can provide a unique key for storage.
public protocol Keyable {
    
    /// The unique key for the instance.
    var key: String { get }
    
    /// A static unique key for the type.
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
