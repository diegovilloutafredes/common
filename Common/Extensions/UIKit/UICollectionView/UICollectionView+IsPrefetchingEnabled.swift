//
//  UICollectionView+IsPrefetchingEnabled.swift
//

import UIKit

extension UICollectionView {
    @discardableResult public func isPrefetchingEnabled(_ isPrefetchingEnabled: Bool) -> Self {
        with { $0.isPrefetchingEnabled = isPrefetchingEnabled }
    }
}
