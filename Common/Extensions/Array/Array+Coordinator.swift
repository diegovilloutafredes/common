//
//  Array+Coordinator.swift
//

// MARK: - Array convenience Extension
extension Array where Element == Coordinator {
    public func getFirst<T: Coordinator>(_ type: T.Type) -> T? { first { $0 is T } as? T }

    public mutating func removeAll<T: Coordinator>(_ type: T.Type) {
        guard getFirst(type).isNotNil else { return }
        removeAll { $0 is T }
    }
}
