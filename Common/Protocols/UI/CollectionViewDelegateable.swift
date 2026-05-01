//
//  CollectionViewDelegateable.swift
//

// MARK: - CollectionViewDelegateable
/// A protocol that defines the delegate requirements for a collection view.
@MainActor
public protocol CollectionViewDelegateable: AnyObject {
    
    /// Notifies the delegate that an item has been selected.
    /// - Parameters:
    ///   - section: The section index.
    ///   - index: The item index.
    func onItemSelected(in section: Int, at index: Int)
}

extension CollectionViewDelegateable {
    public func onItemSelected(in section: Int, at index: Int) {}
}
