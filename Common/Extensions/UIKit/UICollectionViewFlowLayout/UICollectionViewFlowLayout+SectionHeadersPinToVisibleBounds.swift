//
//  UICollectionViewFlowLayout+SectionHeadersPinToVisibleBounds.swift
//

import UIKit

extension UICollectionViewFlowLayout {
    @discardableResult public func sectionHeadersPinToVisibleBounds(_ sectionHeadersPinToVisibleBounds: Bool) -> Self {
        with { $0.sectionHeadersPinToVisibleBounds = sectionHeadersPinToVisibleBounds }
    }
}
