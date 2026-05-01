//
//  InMemoryKeyValueStorage.swift
//

import Foundation

// MARK: - InMemoryKeyValueStorage

/// An in-memory `KeyValueStorage` backed by a `[String: Data]` dictionary.
///
/// Use this as a test or preview backend:
/// ```swift
/// let store = KeyValueStore(keyValueStorage: InMemoryKeyValueStorage())
/// ```
/// Call `reset()` in `tearDown` to clear state between tests.
public final class InMemoryKeyValueStorage: KeyValueStorage {

    private var store: [String: Data] = [:]

    public init() {}

    // MARK: - KeyValueStorage

    public func add(item: KeyValue<Storable>) {
        guard let data = item.value.asData() else { return }
        store[item.key] = data
    }

    public func add(item: KeyStorable) {
        add(item: (item.key, item))
    }

    public func get<T: Storable>(using key: String) -> T? {
        store[key]?.decoded()
    }

    public func remove(using key: String) {
        store[key] = nil
    }

    // MARK: - Result-based API

    public func tryAdd(item: KeyValue<Storable>) -> Result<Void, StorageError> {
        guard let data = item.value.asData() else {
            return .failure(.encodingFailed(CocoaError(.coderInvalidValue)))
        }
        store[item.key] = data
        return .success(())
    }

    public func tryGet<T: Storable>(using key: String) -> Result<T?, StorageError> {
        guard let data = store[key] else { return .success(nil) }
        guard let value: T = data.decoded() else {
            return .failure(.decodingFailed(CocoaError(.coderReadCorrupt)))
        }
        return .success(value)
    }

    public func tryRemove(using key: String) -> Result<Void, StorageError> {
        store[key] = nil
        return .success(())
    }

    // MARK: - Test helpers

    /// Clears all stored entries. Call in `tearDown` between tests.
    public func reset() {
        store.removeAll()
    }
}
