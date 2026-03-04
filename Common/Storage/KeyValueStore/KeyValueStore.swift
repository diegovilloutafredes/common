//
//  KeyValueStore.swift
//

import Foundation

// MARK: - KeyValueStore

/// A unified interface for key-value storage implementations.
public struct KeyValueStore {
    
    /// Defines the types of storage available.
    public enum StoreType {
        
        /// Non-secure storage types.
        public enum NotSecureType {
            /// Uses `UserDefaults`.
            case userDefaults
            /// Uses file system storage.
            case files
        }

        /// Non-secure storage.
        case notSecure(NotSecureType)
        /// Secure storage (Keychain).
        case secure

        /// Returns the underlying `KeyValueStorage` implementation for the type.
        public var storage: KeyValueStorage {
            switch self {
            case .notSecure(let type):
                switch type {
                case .userDefaults: UserDefaults.standard
                case .files: FileStorage.shared
                }
            case .secure: KeychainWrapper.standard
            }
        }
    }

    private let keyValueStorage: KeyValueStorage

    /// Initializes with a specific `KeyValueStorage` implementation.
    /// - Parameter keyValueStorage: The storage implementation to use.
    public init(keyValueStorage: KeyValueStorage) {
        self.keyValueStorage = keyValueStorage
    }

    /// Initializes with a storage type.
    /// - Parameter type: The type of storage to use. Defaults to `.notSecure(.userDefaults)`.
    public init(type: StoreType = .notSecure(.userDefaults)) {
        keyValueStorage = type.storage
    }
}

// MARK: - KeyValueStorage
extension KeyValueStore: KeyValueStorage {
    
    /// Adds a key-value pair to the underlying storage.
    public func add(item: KeyValue<Storable>) { keyValueStorage.add(item: item) }
    
    /// Adds a `KeyStorable` item to the underlying storage.
    public func add(item: KeyStorable) { add(item: (item.key, item)) }
    
    /// Retrieves an item from the underlying storage.
    public func get<T: Storable>(using key: String) -> T? { keyValueStorage.get(using: key) }
    
    /// Removes an item from the underlying storage.
    public func remove(using key: String) { keyValueStorage.remove(using: key) }
}
