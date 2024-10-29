//
//  UICollectionViewFlowLayout+MinimumLineSpacing.swift
//

import UIKit

extension UICollectionViewFlowLayout {
    @discardableResult public func minimumLineSpacing(_ minimumLineSpacing: CGFloat) -> Self {
        with { $0.minimumLineSpacing = minimumLineSpacing }
    }
}
