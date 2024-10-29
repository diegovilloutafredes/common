//
//  CollectionViewDataSourceable.swift
//

// MARK: - CollectionViewDataSourceable
public protocol CollectionViewDataSourceable: AnyObject {
    func getNumberOfSections() -> Int
    func getNumberOfItems(in section: Int) -> Int
    func onCellForItem(in section: Int, at index: Int) -> ViewModel?
    func onHeaderItemDataSourceRequested(in section: Int) -> ViewModel?
    func onHeaderItemReuseIdentifierRequested(in section: Int) -> String
    func onReuseIdentifierRequested(in section: Int, at index: Int) -> String
}

// MARK: - Default implementation
extension CollectionViewDataSourceable {
    public func getNumberOfSections() -> Int { 1 }
    public func onHeaderItemDataSourceRequested(in section: Int) -> ViewModel? { nil }
    public func onHeaderItemReuseIdentifierRequested(in section: Int) -> String { .empty }
}
