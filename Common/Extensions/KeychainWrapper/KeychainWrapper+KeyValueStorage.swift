//
//  KeychainWrapper+KeyValueStorage.swift
//

import Foundation

extension KeychainWrapper: KeyValueStorage {
    public func add(item: (key: String, value: Storable), completion: CompletionHandler) {
        guard let data = item.value.encoded else { return }
        set(data, forKey: item.key)
        completion?()
    }

    public func add(item: KeyStorable, completion: CompletionHandler) {
        add(item: (key: item.key, value: item), completion: completion)
    }

    public func get<T: Storable>(using key: String) -> T? {
        data(forKey: key)?.decoded()
    }

    public func remove(using key: String, completion: CompletionHandler) {
        removeObject(forKey: key)
        completion?()
    }
}
