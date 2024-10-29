//
//  CollectionViewDelegateable.swift
//

// MARK: - CollectionViewDelegateable
public protocol CollectionViewDelegateable: AnyObject {
    func onItemSelected(in section: Int, at index: Int)
}

extension CollectionViewDelegateable {
    public func onItemSelected(in section: Int, at index: Int) {}
}
