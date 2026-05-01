//
//  Loggable.swift
//

import os

// MARK: - Loggable
/// A protocol that providing logging capabilities to conforming types.
public protocol Loggable: Keyable {

    /// Determines whether logging is enabled.
    static var shouldLog: Bool { get }
}

// Protocol extensions cannot have stored properties, so the store and
// per-type cache live at module scope. The store is initialised lazily on
// first access (inside the cache lock) to avoid Keychain access at import time.
private nonisolated(unsafe) var _loggableStoreStorage: KeyValueStore? = nil
private let _loggableCache = OSAllocatedUnfairLock<[String: Bool]>(initialState: [:])

private var _loggableStore: KeyValueStore {
    _loggableCache.withLock { _ in
        if _loggableStoreStorage == nil { _loggableStoreStorage = KeyValueStore(type: .secure) }
        return _loggableStoreStorage!
    }
}

// MARK: - Default implementation
extension Loggable {
    public static var shouldLog: Bool {
        get {
            guard Logger.isCompileTimeEnabled else { return false }
            let key = "\(staticKey).shouldLog"
            if let cached = _loggableCache.withLock({ $0[key] }) { return cached }
            #if DEBUG
            let defaultValue = true
            #else
            let defaultValue = false
            #endif
            let value: Bool = _loggableStore.get(using: key) ?? defaultValue
            _loggableCache.withLock { $0[key] = value }
            return value
        }
        set {
            guard Logger.isCompileTimeEnabled else { return }
            let key = "\(staticKey).shouldLog"
            _loggableCache.withLock { $0[key] = newValue }
            _loggableStore.add(item: (key: key, value: newValue))
        }
    }
}
