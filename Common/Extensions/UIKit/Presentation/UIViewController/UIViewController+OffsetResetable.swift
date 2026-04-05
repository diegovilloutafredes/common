//
//  UIViewController+ResetCollectionViewOffsetIfNeeded.swift
//

import UIKit

// MARK: - OffsetResetable
// MARK: - OffsetResetable

/// Protocol defining methods to reset the content offset of scroll views and collection views.
public protocol OffsetResetable {
    /// Resets the content offset of both the closest scroll view and collection view.
    func resetOffsetIfNeeded()
    
    /// Resets the content offset of the closest collection view.
    func resetCollectionViewOffsetIfNeeded()
    
    /// Resets the content offset of the closest scroll view.
    func resetScrollViewOffsetIfNeeded()
}

// MARK: - where Self: UIViewController
extension OffsetResetable where Self: UIViewController {
    
    /// Resets the content offset of both the closest scroll view and collection view.
    public func resetOffsetIfNeeded() {
        resetCollectionViewOffsetIfNeeded()
        resetScrollViewOffsetIfNeeded()
    }

    /// Resets the content offset of the closest scroll view if it is not at the top.
    public func resetScrollViewOffsetIfNeeded() {
        guard closestScrollView?.contentOffset != .zero else { return }
        closestScrollView?.setContentOffset(.zero, animated: true)
    }

    /// Resets the content offset of the closest collection view if it is not at the top.
    public func resetCollectionViewOffsetIfNeeded() {
        guard closestCollectionView?.contentOffset != .zero else { return }
        closestCollectionView?.setContentOffset(.zero, animated: true)
    }
}

// MARK: - OffsetResetable
extension UIViewController: OffsetResetable {}


extension UIViewController {
    
    /// The closest `UICollectionView` found in the view hierarchy.
    public var closestCollectionView: UICollectionView? { getClosest() }
    
    /// The closest `UIScrollView` found in the view hierarchy.
    public var closestScrollView: UIScrollView? { getClosest() }
}

extension UIViewController {
    
    /// Finds the closest view of type `T` in the view hierarchy.
    /// - Returns: The closest view of type `T` or nil if none found.
    public func getClosest<T: UIView>() -> T? {
        guard let sv = view as? T else { return view.subviews.compactMap { getClosest(from: $0) }.first }
        return sv
    }
}

extension UIViewController {
    
    /// Finds the closest `UICollectionView` recursively starting from the given view.
    /// - Parameter view: The view to start searching from.
    /// - Returns: The closest `UICollectionView` or nil if none found.
    public func closestCollectionView(from view: UIView) -> UICollectionView? { getClosest(from: view) }
    
    /// Finds the closest `UIScrollView` recursively starting from the given view.
    /// - Parameter view: The view to start searching from.
    /// - Returns: The closest `UIScrollView` or nil if none found.
    public func closestScrollView(from view: UIView) -> UIScrollView? { getClosest(from: view) }
}

extension UIViewController {
    
    /// Helper method to find the closest view of type `T` recursively from a given view.
    /// - Parameter view: The view to start searching from.
    /// - Returns: The closest view of type `T`, or nil.
    public func getClosest<T: UIView>(from view: UIView) -> T? {
        guard let sv = view as? T else { return view.subviews.compactMap { getClosest(from: $0) }.first }
        return sv
    }
}
