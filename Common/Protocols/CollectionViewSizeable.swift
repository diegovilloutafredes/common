//
//  CollectionViewSizeable.swift
//

public typealias Inset = (top: Double, left: Double, bottom: Double, right: Double)
public typealias Size = (width: Double, height: Double)

// MARK: - CollectionViewSizeable
public protocol CollectionViewSizeable: AnyObject {
    func onMinimumInteritemSpacingFor(section: Int) -> Double
    func onMinimumLineSpacingFor(section: Int) -> Double
    func onSizeForHeaderItem(in section: Int) -> Size
    func onSizeForItem(in section: Int, at index: Int) -> Size
    func onInsetFor(section: Int) -> Inset
}

extension CollectionViewSizeable {
    public func onMinimumInteritemSpacingFor(section: Int) -> Double { .zero }
    public func onMinimumLineSpacingFor(section: Int) -> Double { .zero }
    public func onSizeForHeaderItem(in section: Int) -> Size { (.zero, .zero) }
    public func onInsetFor(section: Int) -> Inset { (.zero, .zero, .zero, .zero) }
}
