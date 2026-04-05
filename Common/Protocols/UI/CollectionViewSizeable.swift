//
//  CollectionViewSizeable.swift
//

public typealias Inset = (top: Double, left: Double, bottom: Double, right: Double)
public typealias Size = (width: Double, height: Double)

// MARK: - CollectionViewSizeable
// MARK: - CollectionViewSizeable
/// A protocol that defines the size and spacing requirements for a collection view layout.
public protocol CollectionViewSizeable: AnyObject {
    
    /// Returns the minimum inter-item spacing for the specified section.
    func onMinimumInteritemSpacingFor(section: Int) -> Double
    
    /// Returns the minimum line spacing for the specified section.
    func onMinimumLineSpacingFor(section: Int) -> Double
    
    /// Returns the size for the header item in the specified section.
    func onSizeForHeaderItem(in section: Int) -> Size
    
    /// Returns the size for the cell at the specified path.
    /// - Parameters:
    ///   - section: The section index.
    ///   - index: The item index.
    func onSizeForItem(in section: Int, at index: Int) -> Size
    
    /// Returns the layout insets for the specified section.
    func onInsetFor(section: Int) -> Inset
}

extension CollectionViewSizeable {
    public func onMinimumInteritemSpacingFor(section: Int) -> Double { .zero }
    public func onMinimumLineSpacingFor(section: Int) -> Double { .zero }
    public func onSizeForHeaderItem(in section: Int) -> Size { (.zero, .zero) }
    public func onInsetFor(section: Int) -> Inset { (.zero, .zero, .zero, .zero) }
}
