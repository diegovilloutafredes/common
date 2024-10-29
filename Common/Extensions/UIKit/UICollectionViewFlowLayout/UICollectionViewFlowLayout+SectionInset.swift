//
//  UICollectionViewFlowLayout+SectionInset.swift
//

import UIKit

extension UICollectionViewFlowLayout {
    @discardableResult public func sectionInset(_ sectionInset: UIEdgeInsets) -> Self {
        with { $0.sectionInset = sectionInset }
    }
}
