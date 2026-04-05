//
//  UICollectionViewFlowLayout+SectionInset.swift
//

import UIKit

extension UICollectionViewFlowLayout {
    
    /// Sets the section insets and returns self (chainable).
    /// - Parameter sectionInset: The insets to apply.
    @discardableResult public func sectionInset(_ sectionInset: UIEdgeInsets) -> Self {
        with { $0.sectionInset = sectionInset }
    }
}
