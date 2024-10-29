//
//  UICollectionView+DataSource.swift
//

import UIKit

extension UICollectionView {
    @discardableResult public func dataSource(_ dataSource: UICollectionViewDataSource) -> Self {
        with { $0.dataSource = dataSource }
    }
}
