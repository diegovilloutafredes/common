//
//  UICollectionView+Delegate.swift
//

import UIKit

extension UICollectionView {
    
    /// Sets the delegate and returns self (chainable).
    /// - Parameter delegate: The delegate object.
    @discardableResult public func delegate(_ delegate: UICollectionViewDelegate) -> Self {
        with { $0.delegate = delegate }
    }
}
