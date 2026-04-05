//
//  UICollectionView+DataSource.swift
//

import UIKit

extension UICollectionView {
    
    /// Sets the data source and returns self (chainable).
    /// - Parameter dataSource: The data source object.
    @discardableResult public func dataSource(_ dataSource: UICollectionViewDataSource) -> Self {
        with { $0.dataSource = dataSource }
    }
}
