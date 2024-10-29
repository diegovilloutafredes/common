//
//  UICollectionView+PrefetchDataSource.swift
//

import UIKit

extension UICollectionView {
    @discardableResult public func prefetchDataSource(_ prefetchDataSource: UICollectionViewDataSourcePrefetching) -> Self {
        with { $0.prefetchDataSource = prefetchDataSource }
    }
}
