//
//  KeyStorable.swift
//

// MARK: - KeyStorable
public protocol KeyStorable: Storable {
    var key: String { get }
    static var staticKey: String { get }
}

// MARK: - Default Implementation
extension KeyStorable {
    public var key: String { .init(describing: self) }
    public static var staticKey: String { .init(describing: self) }
}

extension KeyStorable where Self: RawRepresentable, RawValue == String {
    public var key: String { rawValue }
}

extension KeyStorable where Self: Stringable {
    public var key: String { self.asString }
}
