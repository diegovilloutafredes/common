//
//  Loggable.swift
//

// MARK: - Loggable
// MARK: - Loggable
/// A protocol that providing logging capabilities to conforming types.
public protocol Loggable: Keyable {
    
    /// Determines whether logging is enabled.
    static var shouldLog: Bool { get }
}

// MARK: - Default implementation
extension Loggable {
    private static var store: KeyValueStore { .init(type: .secure) }
    public static var shouldLog: Bool {
        get { store.get(using: "\(staticKey).shouldLog") ?? true }
        set { store.add(item: (key: "\(staticKey).shouldLog", value: newValue)) }
    }
}
