//
//  SingleObjectStorage.swift
//

// MARK: - SingleObjectStorage
public protocol SingleObjectStorage {
    associatedtype Item: Storable
    func add(item: Storable, completion: CompletionHandler)
    func delete(completion: CompletionHandler)
    func get()->Item?
}
