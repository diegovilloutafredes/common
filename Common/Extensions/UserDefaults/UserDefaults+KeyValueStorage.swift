//
//  UserDefaults+KeyValueStorage.swift
//

import Foundation

extension UserDefaults: KeyValueStorage {
    
    /// Adds a value to UserDefaults using a key-value pair tuple.
    /// - Parameter item: A tuple containing the key and the stored value.
    public func add(item: (key: String, value: Storable)) {
        guard let data = item.value.asData() else { return }
        set(data, forKey: item.key)
    }

    /// Adds a value to UserDefaults using a KeyStorable item.
    /// - Parameter item: The item to store (contains both key and value).
    public func add(item: KeyStorable) {
        add(item: (key: item.key, value: item))
    }

    /// Retrieves a storable value from UserDefaults.
    /// - Parameter key: The key associated with the value.
    /// - Returns: The retrieved value of type T, or `nil` if not found or decoding fails.
    public func get<T: Storable>(using key: String) -> T? {
        data(forKey: key)?.decoded()
    }

    /// Removes a value from UserDefaults.
    /// - Parameter key: The key of the value to remove.
    public func remove(using key: String) {
        removeObject(forKey: key)
    }
}
