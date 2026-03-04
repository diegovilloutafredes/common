//
//  List.swift
//

import UIKit

// MARK: - List
// MARK: - List

/// A base list component inheriting from `UICollectionView`.
/// It provides common configuration like preventing content inset adjustments and handling prefetching.
public class List: UICollectionView {
    
    /// Initializes a new list with the specified components.
    /// - Parameters:
    ///   - dataSource: The data source for the list.
    ///   - delegate: The delegate for the list.
    ///   - prefetchDataSource: The prefetch data source for the list.
    ///   - collectionViewLayout: The layout to use.
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
