//
//  UICollectionViewFlowLayout+MinimumInteritemSpacing.swift
//

import UIKit

extension UICollectionViewFlowLayout {
    @discardableResult public func minimumInteritemSpacing(_ minimumInteritemSpacing: CGFloat) -> Self {
        with { $0.minimumInteritemSpacing = minimumInteritemSpacing }
    }
}
