//
//  Loggable.swift
//

// MARK: - Loggable
public protocol Loggable: Keyable {
    static var shouldLog: Bool { get }
}

// MARK: - Default implementation
extension Loggable {
    private static var store: KeyValueStore { .init() }
    public static var shouldLog: Bool {
        get { store.get(using: "\(staticKey).shouldLog") ?? true }
        set { store.add(item: (key: "\(staticKey).shouldLog", value: newValue)) }
    }
}
