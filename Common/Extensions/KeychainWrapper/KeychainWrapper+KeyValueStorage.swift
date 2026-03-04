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
}
