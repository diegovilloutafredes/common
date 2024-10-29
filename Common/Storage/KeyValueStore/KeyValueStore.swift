//
//  KeyValueStore.swift
//

import Foundation

// MARK: - KeyValueStore
public struct KeyValueStore {
    public enum StoreType {
        public enum NotSecureType {
            case userDefaults
            case files
        }

        case notSecure(NotSecureType)
        case secure

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

    public init(keyValueStorage: KeyValueStorage) {
        self.keyValueStorage = keyValueStorage
    }

    public init(type: StoreType = .notSecure(.userDefaults)) {
        keyValueStorage = type.storage
    }
}

// MARK: - KeyValueStorage
extension KeyValueStore: KeyValueStorage {
    public func add(item: KeyValue<Storable>, completion: CompletionHandler = nil) { keyValueStorage.add(item: item, completion: completion) }
    public func add(item: KeyStorable, completion: CompletionHandler = nil) { add(item: (item.key, item), completion: completion) }
    public func get<T: Storable>(using key: String) -> T? { keyValueStorage.get(using: key) }
    public func remove(using key: String, completion: CompletionHandler = nil) { keyValueStorage.remove(using: key, completion: completion) }
}
