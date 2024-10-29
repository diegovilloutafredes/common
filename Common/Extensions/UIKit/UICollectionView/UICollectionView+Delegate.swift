//
//  UICollectionView+Delegate.swift
//

import UIKit

extension UICollectionView {
    @discardableResult public func delegate(_ delegate: UICollectionViewDelegate) -> Self {
        with { $0.delegate = delegate }
    }
}
