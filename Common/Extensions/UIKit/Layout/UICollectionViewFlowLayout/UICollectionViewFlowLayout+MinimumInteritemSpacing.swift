//
//  UICollectionViewFlowLayout+MinimumInteritemSpacing.swift
//

import UIKit

extension UICollectionViewFlowLayout {
    
    /// Sets the minimum spacing between items in the same row or column and returns self (chainable).
    /// - Parameter minimumInteritemSpacing: The spacing value.
    @discardableResult public func minimumInteritemSpacing(_ minimumInteritemSpacing: CGFloat) -> Self {
        with { $0.minimumInteritemSpacing = minimumInteritemSpacing }
    }
}
