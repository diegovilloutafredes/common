//
//  Stringable.swift
//

// MARK: - Stringable
// MARK: - Stringable
/// A protocol for types that can be represented as a `String`.
public protocol Stringable {
    
    /// The string representation of the object.
    var asString: String { get }
}

// MARK: - where Self: RawRepresentable, RawValue == String
extension Stringable where Self: RawRepresentable, RawValue == String {
    public var asString: String { rawValue }
}
