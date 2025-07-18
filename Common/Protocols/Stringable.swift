//
//  Stringable.swift
//

// MARK: - Stringable
public protocol Stringable {
    var asString: String { get }
}

// MARK: - where Self: RawRepresentable, RawValue == String
extension Stringable where Self: RawRepresentable, RawValue == String {
    public var asString: String { rawValue }
}
