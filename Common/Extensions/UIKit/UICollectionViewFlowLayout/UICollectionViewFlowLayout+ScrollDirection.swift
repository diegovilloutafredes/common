//
//  UICollectionViewFlowLayout+ScrollDirection.swift
//

import UIKit

extension UICollectionViewFlowLayout {
    @discardableResult public func scrollDirection(_ scrollDirection: UICollectionView.ScrollDirection) -> Self {
        with { $0.scrollDirection = scrollDirection }
    }
}
