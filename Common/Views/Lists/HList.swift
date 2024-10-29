//
//  HList.swift
//

import UIKit

// MARK: - HList
public final class HList: List {
    public init(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegate? = nil, prefetchDataSource: UICollectionViewDataSourcePrefetching? = nil, layoutHandler: Handler<UICollectionViewFlowLayout>? = nil) {
        let collectionViewLayout = UICollectionViewFlowLayout()
            .scrollDirection(.horizontal)
        layoutHandler?(collectionViewLayout)
        super.init(dataSource: dataSource, delegate: delegate, prefetchDataSource: prefetchDataSource, collectionViewLayout: collectionViewLayout)
        alwaysBounceVertical(false)
    }
}
