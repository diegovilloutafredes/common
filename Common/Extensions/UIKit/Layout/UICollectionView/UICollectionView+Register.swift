//
//  UICollectionView+Register.swift
//

import UIKit

extension UICollectionView {
    
    /// Registers cell classes for reuse.
    /// - Parameter cellClass: Variadic list of cell classes to register.
    @discardableResult public func register(_ cellClass: UICollectionReusableView.Type...) -> Self {
        with { collectionView in cellClass.forEach { collectionView.register($0, forCellWithReuseIdentifier: $0.reuseIdentifier) } }
    }
}

extension UICollectionView {
    
    /// Registers reusable view classes for a specific kind.
    /// - Parameters:
    ///   - reusableViewClass: Variadic list of reusable view classes to register.
    ///   - kind: The kind of supplementary view (header or footer).
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
