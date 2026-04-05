//
//  UICollectionView+BackgroundView.swift
//

import UIKit

extension UICollectionView {
    
    /// Sets the background view of the collection view and returns self (chainable).
    /// - Parameter backgroundView: The view to set as background.
    @discardableResult public func backgroundView(_ backgroundView: UIView) -> Self {
        with { $0.backgroundView = backgroundView }
    }
}
