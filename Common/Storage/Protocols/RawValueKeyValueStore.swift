//
//  RawValueKeyValueStore.swift
//

// MARK: - RawValueKeyValueStore
// MARK: - RawValueKeyValueStore
/// A protocol combining `RawValueKeyableStorage` with a key-value storage mechanism.
public protocol RawValueKeyValueStore: RawValueKeyableStorage {}


// MARK: - Default Implementation where Keys.RawValue == String
extension RawValueKeyValueStore where Keys.RawValue == String {
    private var type: KeyValueStore.StoreType { .notSecure(.userDefaults) }
    private var store: KeyValueStore { .init(type: type) }
    public func add(item: Tuple<Keys, Storable>) { store.add(item: (item.key.rawValue, item.value)) }
    public func add(item: KeyStorable) { store.add(item: (item.key, item)) }
    public func get<T: Storable>(using key: Keys) -> T? { store.get(using: key.rawValue) }
    public func remove(using key: Keys) { store.remove(using: key.rawValue) }
}
