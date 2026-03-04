//
//  UICollectionView+PrefetchDataSource.swift
//

import UIKit

extension UICollectionView {
    
    /// Sets the prefetch data source and returns self (chainable).
    /// - Parameter prefetchDataSource: The prefetch data source object.
    @discardableResult public func prefetchDataSource(_ prefetchDataSource: UICollectionViewDataSourcePrefetching) -> Self {
        with { $0.prefetchDataSource = prefetchDataSource }
    }
}
