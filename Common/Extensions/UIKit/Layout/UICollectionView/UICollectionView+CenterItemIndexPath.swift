//
//  UICollectionView+CenterItemIndexPath.swift
//

import UIKit

extension UICollectionView {
    
    /// Returns the index path of the item at the center of the collection view.
    public var centerItemIndexPath: IndexPath? { indexPathForItem(at: bounds.center) }
}
