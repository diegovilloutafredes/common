//
//  UICollectionView+IsPrefetchingEnabled.swift
//

import UIKit

extension UICollectionView {
    
    /// Sets whether prefetching is enabled and returns self (chainable).
    /// - Parameter isPrefetchingEnabled: `true` to enable prefetching, `false` otherwise.
    @discardableResult public func isPrefetchingEnabled(_ isPrefetchingEnabled: Bool) -> Self {
        with { $0.isPrefetchingEnabled = isPrefetchingEnabled }
    }
}
