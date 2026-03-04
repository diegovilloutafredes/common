//
//  UICollectionViewFlowLayout+ScrollDirection.swift
//

import UIKit

extension UICollectionViewFlowLayout {
    
    /// Sets the scroll direction and returns self (chainable).
    /// - Parameter scrollDirection: The scroll direction.
    @discardableResult public func scrollDirection(_ scrollDirection: UICollectionView.ScrollDirection) -> Self {
        with { $0.scrollDirection = scrollDirection }
    }
}
