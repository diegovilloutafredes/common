//
//  UICollectionViewFlowLayout+SectionHeadersPinToVisibleBounds.swift
//

import UIKit

extension UICollectionViewFlowLayout {
    
    /// Sets whether section headers should pin to visible bounds and returns self (chainable).
    /// - Parameter sectionHeadersPinToVisibleBounds: `true` to pin headers, `false` otherwise.
    @discardableResult public func sectionHeadersPinToVisibleBounds(_ sectionHeadersPinToVisibleBounds: Bool) -> Self {
        with { $0.sectionHeadersPinToVisibleBounds = sectionHeadersPinToVisibleBounds }
    }
}
