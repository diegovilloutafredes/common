//
//  Keyable.swift
//

// MARK: - Keyable
public protocol Keyable {
    var key: String { get }
    static var staticKey: String { get }
}

extension Keyable {
    public var key: String { .init(describing: self) }
    public static var staticKey: String { .init(describing: self) }
}

extension Keyable where Self: RawRepresentable, RawValue == String {
    public var key: String { rawValue }
}

extension Keyable where Self: Stringable {
    public var key: String { self.asString }
}
