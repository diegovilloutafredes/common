//
//  UIViewController+ResetCollectionViewOffsetIfNeeded.swift
//

import UIKit

// MARK: - OffsetResetable
public protocol OffsetResetable {
    func resetOffsetIfNeeded()
    func resetCollectionViewOffsetIfNeeded()
    func resetScrollViewOffsetIfNeeded()
}

// MARK: - where Self: UIViewController
extension OffsetResetable where Self: UIViewController {
    public func resetOffsetIfNeeded() {
        resetCollectionViewOffsetIfNeeded()
        resetScrollViewOffsetIfNeeded()
    }

    public func resetScrollViewOffsetIfNeeded() {
        guard closestScrollView?.contentOffset != .zero else { return }
        closestScrollView?.setContentOffset(.zero, animated: true)
    }

    public func resetCollectionViewOffsetIfNeeded() {
        guard closestCollectionView?.contentOffset != .zero else { return }
        closestCollectionView?.setContentOffset(.zero, animated: true)
    }
}

// MARK: - OffsetResetable
extension UIViewController: OffsetResetable {}





extension UIViewController {
    public var closestCollectionView: UICollectionView? { getClosest() }
    public var closestScrollView: UIScrollView? { getClosest() }
}

extension UIViewController {
    public func closestCollectionView(from view: UIView) -> UICollectionView? { getClosest(from: view) }
    public func closestScrollView(from view: UIView) -> UIScrollView? { getClosest(from: view) }
}

extension UIViewController {
    public func getClosest<T: UIView>(from view: UIView) -> T? {
        guard let sv = view as? T else { return view.subviews.compactMap { getClosest(from: $0) }.first }
        return sv
    }
}

extension UIViewController {
    public func getClosest<T: UIView>() -> T? {
        guard let sv = view as? T else { return view.subviews.compactMap { getClosest(from: $0) }.first }
        return sv
    }
}
