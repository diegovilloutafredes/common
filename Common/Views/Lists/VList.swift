//
//  VList.swift
//

import UIKit

// MARK: - VList
// MARK: - VList

/// A vertically scrolling list built on top of `List` (UICollectionView).
public final class VList: List {
    
    /// Initializes a new vertical list.
    /// - Parameters:
    ///   - dataSource: The data source for the collection view.
    ///   - delegate: The delegate for the collection view.
    ///   - prefetchDataSource: The prefetch data source.
    ///   - layoutHandler: A closure to configure the `UICollectionViewFlowLayout`.
    public init(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegate? = nil, prefetchDataSource: UICollectionViewDataSourcePrefetching? = nil, layoutHandler: Handler<UICollectionViewFlowLayout>? = nil) {
        let collectionViewLayout = UICollectionViewFlowLayout().scrollDirection(.vertical)
        layoutHandler?(collectionViewLayout)
        super.init(dataSource: dataSource, delegate: delegate, prefetchDataSource: prefetchDataSource, collectionViewLayout: collectionViewLayout)
    }
}
