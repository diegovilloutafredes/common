//
//  UICollectionViewFlowLayout+MinimumLineSpacing.swift
//

import UIKit

extension UICollectionViewFlowLayout {
    
    /// Sets the minimum spacing between lines and returns self (chainable).
    /// - Parameter minimumLineSpacing: The spacing value.
    @discardableResult public func minimumLineSpacing(_ minimumLineSpacing: CGFloat) -> Self {
        with { $0.minimumLineSpacing = minimumLineSpacing }
    }
}
