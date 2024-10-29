//
//  UICollectionView+BackgroundView.swift
//

import UIKit

extension UICollectionView {
    @discardableResult public func backgroundView(_ backgroundView: UIView) -> Self {
        with { $0.backgroundView = backgroundView }
    }
}
