//
//  UICollectionView+CenterItemIndexPath.swift
//

import UIKit

extension UICollectionView {
    public var centerItemIndexPath: IndexPath? { indexPathForItem(at: bounds.center) }
}
