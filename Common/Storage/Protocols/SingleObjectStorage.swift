//
//  SingleObjectStorage.swift
//

// MARK: - SingleObjectStorage
// MARK: - SingleObjectStorage
/// A protocol for storage that manages a single object of a specific type.
public protocol SingleObjectStorage {
    
    /// The type of item stored.
    associatedtype Item: Storable
    
    /// Adds or updates the single stored item.
    /// - Parameter item: The item to store.
    func add(item: Item)
    
    /// Deletes the stored item.
    func delete()
    
    /// Retrieves the stored item.
    /// - Returns: The stored item, or `nil` if not present.
    func get()->Item?
}
