//
//  UICollectionView+Register.swift
//

import UIKit

extension UICollectionView {
    @discardableResult public func register(_ cellClass: UICollectionReusableView.Type...) -> Self {
        with { collectionView in cellClass.forEach { collectionView.register($0, forCellWithReuseIdentifier: $0.reuseIdentifier) } }
    }
}

extension UICollectionView {
    @discardableResult public func register(_ reusableViewClass: UICollectionReusableView.Type..., kind: SupplementaryViewKind) -> Self {
        with { collectionView in reusableViewClass.forEach { collectionView.register($0, forSupplementaryViewOfKind: kind.asString, withReuseIdentifier: $0.reuseIdentifier) }
        }
    }
}

// MARK: - SupplementaryViewKind
public enum SupplementaryViewKind: Stringable {
    case header
    case footer

    public var asString: String {
        switch self {
        case .header: UICollectionView.elementKindSectionHeader
        case .footer: UICollectionView.elementKindSectionFooter
        }
    }
}
