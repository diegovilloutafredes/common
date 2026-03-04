//
//  RawValueKeyableStorage.swift
//

// MARK: - RawValueKeyValueStorage
// MARK: - RawValueKeyValueStorage
/// A storage protocol that uses raw values as keys.
public protocol RawValueKeyableStorage: RawValueKeyable {
    
    /// Adds an item to the storage using a specific key.
    /// - Parameter item: A tuple containing the key and the storable value.
    func add(item: Tuple<Keys, Storable>)
    
    /// Adds a `KeyStorable` item to the storage.
    /// - Parameter item: The item to add. The item's key is used (converted to `Keys`).
    func add(item: KeyStorable)
    
    /// Retrieves an item from storage using a raw value key.
    /// - Parameter key: The key of the item to retrieve.
    /// - Returns: The retrieved item, or `nil` if not found.
    func get<T: Storable>(using key: Keys) -> T?
    
    /// Removes an item from storage using a raw value key.
    /// - Parameter key: The key of the item to remove.
    func remove(using key: Keys)
}

extension RawValueKeyableStorage where Keys.RawValue == String {
    public func add(item: KeyStorable) {
        guard let key = Keys(rawValue: item.key) else { return }
        add(item: (key: key, value: item))
    }
}

extension RawValueKeyableStorage where Self: KeyValueStorage, Keys.RawValue == String {
    public func add(item: Tuple<Keys, Storable>) { add(item: (item.key.rawValue, item.value)) }
    public func add(item: KeyStorable) { add(item: (item.key, item)) }
    public func get<T: Storable>(using key: Keys) -> T? { get(using: key.rawValue) }
    public func remove(using key: Keys) { remove(using: key.rawValue) }
}
