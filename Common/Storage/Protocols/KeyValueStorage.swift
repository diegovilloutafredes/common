//
//  KeyValueStorage.swift
//

// MARK: - Typealias
public typealias Tuple<Key, Value> = (key: Key, value: Value)
public typealias KeyValue<Value> = Tuple<String, Value>

// MARK: - KeyValueStorage
// MARK: - KeyValueStorage
/// A protocol defining a storage mechanism that relies on key-value pairs.
public protocol KeyValueStorage {
    
    /// Adds a key-value pair to the storage.
    /// - Parameter item: A tuple containing the key and the storable value.
    func add(item: KeyValue<Storable>)
    
    /// Adds a `KeyStorable` item to the storage.
    /// - Parameter item: The item to add. The item's key is used for storage.
    func add(item: KeyStorable)
    
    /// Retrieves an item from storage using its key.
    /// - Parameter key: The key of the item to retrieve.
    /// - Returns: The retrieved item, or `nil` if not found.
    func get<T: Storable>(using key: String) -> T?
    
    /// Removes an item from storage using its key.
    /// - Parameter key: The key of the item to remove.
    func remove(using key: String)
}

extension KeyValueStorage {
    public func add(item: KeyStorable) { add(item: (item.key, item)) }
}

// MARK: - extension where Self: RawValueKeyValueStorage, Keys.RawValue == String
extension KeyValueStorage where Self: RawValueKeyableStorage, Keys.RawValue == String {
    public func add(item: KeyValue<Storable>) {
        guard let key = Keys(rawValue: item.key) else { return }
        add(item: (key: key, item.value))
    }

    public func get<T: Storable>(using key: String) -> T? { get(using: key) }

    public func remove(using key: String) {
        guard let key = Keys(rawValue: key) else { return }
        remove(using: key)
    }
}
