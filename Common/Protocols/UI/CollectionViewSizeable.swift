//
//  CollectionViewSizeable.swift
//

/// Section insets as a labeled tuple; `(.zero, .zero, .zero, .zero)` is the default.
public typealias Inset = (top: Double, left: Double, bottom: Double, right: Double)
/// An item, header, or footer size as a labeled tuple; `(.zero, .zero)` means "none" for supplementary views.
public typealias Size = (width: Double, height: Double)

// MARK: - CollectionViewSizeable
/// A protocol that defines the size and spacing requirements for a collection view layout.
@MainActor
public protocol CollectionViewSizeable: AnyObject {
    
    /// Returns the minimum inter-item spacing for the specified section.
    func onMinimumInteritemSpacingFor(section: Int) -> Double
    
    /// Returns the minimum line spacing for the specified section.
    func onMinimumLineSpacingFor(section: Int) -> Double
    
    /// Returns the size for the header item in the specified section. Legacy hook: prefer
    /// `onSizeForHeaderItem(in:availableSize:)`; defaults to `(.zero, .zero)` (no header).
    func onSizeForHeaderItem(in section: Int) -> Size

    /// Returns the size for the header item in the specified section, given the size it may occupy
    /// (see `onSizeForItem(in:at:availableSize:)`). Defaults to forwarding to the legacy hook.
    func onSizeForHeaderItem(in section: Int, availableSize: Size) -> Size

    /// Returns the size for the footer item in the specified section. Legacy hook: prefer
    /// `onSizeForFooterItem(in:availableSize:)`; defaults to `(.zero, .zero)` (no footer).
    func onSizeForFooterItem(in section: Int) -> Size

    /// Returns the size for the footer item in the specified section, given the size it may occupy
    /// (see `onSizeForItem(in:at:availableSize:)`). Defaults to forwarding to the legacy hook.
    func onSizeForFooterItem(in section: Int, availableSize: Size) -> Size
    
    /// Returns the size for the cell at the specified path.
    ///
    /// Legacy hook: implement `onSizeForItem(in:at:availableSize:)` instead in new code. Exactly
    /// one of the two is implemented per conformer — this one defaults to `(.zero, .zero)`, and the
    /// other defaults to forwarding here, so a conformer implementing neither renders an empty list.
    /// - Parameters:
    ///   - section: The section index.
    ///   - index: The item index.
    func onSizeForItem(in section: Int, at index: Int) -> Size

    /// Returns the size for the cell at the specified path, given the size items may occupy.
    ///
    /// `availableSize` is the collection view's bounds inset by its adjusted content inset and by
    /// this section's inset (including the controller's `bottomInsetForLastCollectionSection()`),
    /// each dimension clamped at zero. Full-width rows return `availableSize.width`; a horizontal
    /// list reads `availableSize.height`. No view reference is needed for either.
    /// - Parameters:
    ///   - section: The section index.
    ///   - index: The item index.
    ///   - availableSize: The width and height an item in this section may occupy.
    func onSizeForItem(in section: Int, at index: Int, availableSize: Size) -> Size
    
    /// Returns the layout insets for the specified section.
    func onInsetFor(section: Int) -> Inset
}

extension CollectionViewSizeable {
    public func onMinimumInteritemSpacingFor(section: Int) -> Double { .zero }
    public func onMinimumLineSpacingFor(section: Int) -> Double { .zero }
    public func onSizeForHeaderItem(in section: Int) -> Size { (.zero, .zero) }
    public func onSizeForHeaderItem(in section: Int, availableSize: Size) -> Size { onSizeForHeaderItem(in: section) }
    public func onSizeForFooterItem(in section: Int) -> Size { (.zero, .zero) }
    public func onSizeForFooterItem(in section: Int, availableSize: Size) -> Size { onSizeForFooterItem(in: section) }
    public func onInsetFor(section: Int) -> Inset { (.zero, .zero, .zero, .zero) }
    public func onSizeForItem(in section: Int, at index: Int) -> Size { (.zero, .zero) }
    public func onSizeForItem(in section: Int, at index: Int, availableSize: Size) -> Size {
        onSizeForItem(in: section, at: index)
    }
}
