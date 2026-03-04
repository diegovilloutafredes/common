//
//  Array+Coordinator.swift
//

// MARK: - Array convenience Extension
// MARK: - Array convenience Extension
extension Array where Element == Coordinator {
    
    /// Returns the first coordinator of the specified type.
    /// - Parameter type: The type of coordinator to find.
    /// - Returns: The first coordinator matching the type, or `nil` if not found.
    public func getFirst<T: Coordinator>(_ type: T.Type) -> T? { first { $0 is T } as? T }

    /// Removes all coordinators of the specified type.
    /// - Parameter type: The type of coordinator to remove.
    public mutating func removeAll<T: Coordinator>(_ type: T.Type) {
        guard getFirst(type).isNotNil else { return }
        removeAll { $0 is T }
    }
}
