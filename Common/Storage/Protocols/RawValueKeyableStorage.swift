//
//  RawValueKeyableStorage.swift
//

// MARK: - RawValueKeyValueStorage
public protocol RawValueKeyableStorage: RawValueKeyable {
    func add(item: Tuple<Keys, Storable>, completion: CompletionHandler)
    func add(item: KeyStorable, completion: CompletionHandler)
    func get<T: Storable>(using key: Keys) -> T?
    func remove(using key: Keys, completion: CompletionHandler)
}

extension RawValueKeyableStorage where Keys.RawValue == String {
    public func add(item: KeyStorable, completion: CompletionHandler) {
        guard let key = Keys(rawValue: item.key) else { return }
        add(item: (key: key, value: item), completion: completion)
    }
}

extension RawValueKeyableStorage where Self: KeyValueStorage, Keys.RawValue == String {
    public func add(item: Tuple<Keys, Storable>, completion: CompletionHandler = nil) { add(item: (item.key.rawValue, item.value), completion: completion) }
    public func add(item: KeyStorable, completion: CompletionHandler = nil) { add(item: (item.key, item), completion: completion) }
    public func get<T: Storable>(using key: Keys) -> T? { get(using: key.rawValue) }
    public func remove(using key: Keys, completion: CompletionHandler = nil) { remove(using: key.rawValue, completion: completion) }
}
