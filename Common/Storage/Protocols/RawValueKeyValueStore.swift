//
//  RawValueKeyValueStore.swift
//

// MARK: - RawValueKeyValueStore
/// A protocol combining `RawValueKeyableStorage` with a key-value storage mechanism.
public protocol RawValueKeyValueStore: RawValueKeyableStorage {

    /// The backing store type. Defaults to `.notSecure(.userDefaults)`.
    ///
    /// This must be a protocol requirement: as a plain extension member it would be
    /// statically dispatched, silently ignoring a conformer's declared store type
    /// (e.g. `.secure` would still write to UserDefaults).
    var type: KeyValueStore.StoreType { get }
}

extension RawValueKeyValueStore {
    public var type: KeyValueStore.StoreType { .notSecure(.userDefaults) }
}

// MARK: - Default Implementation where Keys.RawValue == String
extension RawValueKeyValueStore where Keys.RawValue == String {
    private var store: KeyValueStore { .init(type: type) }
    public func add(item: Tuple<Keys, Storable>) { store.add(item: (item.key.rawValue, item.value)) }
    public func add(item: KeyStorable) { store.add(item: (item.key, item)) }
    public func get<T: Storable>(using key: Keys) -> T? { store.get(using: key.rawValue) }
    public func remove(using key: Keys) { store.remove(using: key.rawValue) }
}
