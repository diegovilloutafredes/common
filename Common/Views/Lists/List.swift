//
//  List.swift
//

import UIKit

// MARK: - List
public class List: UICollectionView {
    public init(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegate? = nil, prefetchDataSource: UICollectionViewDataSourcePrefetching? = nil, collectionViewLayout: UICollectionViewLayout) {
        super.init(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.dataSource(dataSource)
        if let delegate { self.delegate(delegate) }

        alwaysBounceVertical(true)
        backgroundColor(.clear)
        contentInsetAdjustmentBehavior(.never)
        showsHorizontalScrollIndicator(false)
        showsVerticalScrollIndicator(false)

        guard let prefetchDataSource else { isPrefetchingEnabled(false); return }
        self.prefetchDataSource(prefetchDataSource)
        isPrefetchingEnabled(true)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("NSCoder is not supported")
    }

    public override class var requiresConstraintBasedLayout: Bool { true }
}
