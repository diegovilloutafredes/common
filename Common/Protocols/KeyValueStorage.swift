//
//  KeyValueStorage.swift
//

public typealias Tuple<Key, Value> = (key: Key, value: Value)
public typealias KeyValue<Value> = Tuple<String, Value>

// MARK: - KeyValueStorage
public protocol KeyValueStorage {
    func add(item: KeyValue<Storable>, completion: CompletionHandler)
    func add(item: KeyStorable, completion: CompletionHandler)
    func get<T: Storable>(using key: String) -> T?
    func remove(using key: String, completion: CompletionHandler)
}

extension KeyValueStorage {
    public func add(item: KeyStorable, completion: CompletionHandler) { add(item: (item.key, item), completion: completion) }
}

// MARK: - extension where Self: RawValueKeyValueStorage, Keys.RawValue == String
extension KeyValueStorage where Self: RawValueKeyableStorage, Keys.RawValue == String {
    public func add(item: KeyValue<Storable>, completion: CompletionHandler = nil) {
        guard let key = Keys(rawValue: item.key) else { return }
        add(item: (key: key, item.value), completion: completion)
    }

    public func get<T: Storable>(using key: String) -> T? { get(using: key) }

    public func remove(using key: String, completion: CompletionHandler = nil) {
        guard let key = Keys(rawValue: key) else { return }
        remove(using: key, completion: completion)
    }
}
