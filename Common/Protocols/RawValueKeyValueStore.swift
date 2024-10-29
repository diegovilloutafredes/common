//
//  RawValueKeyValueStore.swift
//

// MARK: - RawValueKeyValueStore
public protocol RawValueKeyValueStore: RawValueKeyableStorage {}

extension RawValueKeyValueStore where Keys.RawValue == String {
    public var type: KeyValueStore.StoreType { .notSecure(.userDefaults) }
    public var store: KeyValueStore { .init(type: type) }

    public func add(item: Tuple<Keys, Storable>, completion: CompletionHandler = nil) { store.add(item: (item.key.rawValue, item.value), completion: completion) }
    public func add(item: KeyStorable, completion: CompletionHandler = nil) { store.add(item: (item.key, item), completion: completion) }
    public func get<T: Storable>(using key: Keys) -> T? { store.get(using: key.rawValue) }
    public func remove(using key: Keys, completion: CompletionHandler = nil) { store.remove(using: key.rawValue, completion: completion) }
}
