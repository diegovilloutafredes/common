//
//  CollectionViewDataSourceable.swift
//

// MARK: - CollectionViewDataSourceable
// MARK: - CollectionViewDataSourceable
/// A protocol that defines the data source requirements for a collection view.
public protocol CollectionViewDataSourceable: AnyObject {
    
    /// Returns the number of sections in the collection view.
    func getNumberOfSections() -> Int
    
    /// Returns the number of items in the specified section.
    /// - Parameter section: The section index.
    func getNumberOfItems(in section: Int) -> Int
    
    /// returns the view model for the cell at the specified path.
    /// - Parameters:
    ///   - section: The section index.
    ///   - index: The item index.
    func onCellForItem(in section: Int, at index: Int) -> ViewModel?
    
    /// Returns the view model for the header item in the specified section.
    /// - Parameter section: The section index.
    func onHeaderItemDataSourceRequested(in section: Int) -> ViewModel?
    
    /// Returns the reuse identifier for the header in the specified section.
    /// - Parameter section: The section index.
    func onHeaderItemReuseIdentifierRequested(in section: Int) -> String
    
    /// Returns the reuse identifier for the cell at the specified path.
    /// - Parameters:
    ///   - section: The section index.
    ///   - index: The item index.
    func onReuseIdentifierRequested(in section: Int, at index: Int) -> String
}

// MARK: - Default implementation
extension CollectionViewDataSourceable {
    public func getNumberOfSections() -> Int { 1 }
    public func onHeaderItemDataSourceRequested(in section: Int) -> ViewModel? { nil }
    public func onHeaderItemReuseIdentifierRequested(in section: Int) -> String { .empty }
}
