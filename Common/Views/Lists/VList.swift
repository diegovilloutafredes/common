//
//  VList.swift
//

import UIKit

// MARK: - VList
public final class VList: List {
    public init(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegate? = nil, prefetchDataSource: UICollectionViewDataSourcePrefetching? = nil, layoutHandler: Handler<UICollectionViewFlowLayout>? = nil) {
        let collectionViewLayout = UICollectionViewFlowLayout().scrollDirection(.vertical)
        layoutHandler?(collectionViewLayout)
        super.init(dataSource: dataSource, delegate: delegate, prefetchDataSource: prefetchDataSource, collectionViewLayout: collectionViewLayout)
    }
}
