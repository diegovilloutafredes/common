//
//  KeychainWrapper+KeyValueStorage.swift
//

import Foundation

/// Makes KeychainWrapper conform to the KeyValueStorage protocol.
extension KeychainWrapper: KeyValueStorage {
    
    /// Adds an item to the keychain.
    /// - Parameter item: A tuple containing the key and the storable value.
    public func add(item: (key: String, value: Storable)) {
        guard let data = item.value.asData() else { return }
        set(data, forKey: item.key)
    }

    /// Adds a key-storable item to the keychain.
    /// - Parameter item: The item to store, which provides its own key.
    public func add(item: KeyStorable) {
        add(item: (key: item.key, value: item))
    }

    /// Retrieves an item from the keychain.
    /// - Parameter key: The key associated with the item.
    /// - Returns: The retrieved item, or nil if not found or decoding failed.
    public func get<T: Storable>(using key: String) -> T? {
        data(forKey: key)?.decoded()
    }

    /// Removes an item from the keychain.
    /// - Parameter key: The key associated with the item to remove.
    public func remove(using key: String) {
        removeObject(forKey: key)
    }

    // MARK: - Result-based API

    public func tryAdd(item: KeyValue<Storable>) -> Result<Void, StorageError> {
        guard let data = item.value.asData() else {
            return .failure(.encodingFailed(CocoaError(.coderInvalidValue)))
        }
        let status = addOrUpdateStatus(data, forKey: item.key)
        return status == errSecSuccess ? .success(()) : .failure(.keychainError(status))
    }

    public func tryGet<T: Storable>(using key: String) -> Result<T?, StorageError> {
        let (data, status) = getDataStatus(forKey: key)
        if status == errSecItemNotFound { return .success(nil) }
        guard status == errSecSuccess else { return .failure(.keychainError(status)) }
        guard let data, let value: T = data.decoded() else {
            return .failure(.decodingFailed(CocoaError(.coderReadCorrupt)))
        }
        return .success(value)
    }

    public func tryRemove(using key: String) -> Result<Void, StorageError> {
        let status = removeStatus(forKey: key)
        if status == errSecSuccess || status == errSecItemNotFound { return .success(()) }
        return .failure(.keychainError(status))
    }
}
