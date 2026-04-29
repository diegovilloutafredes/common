//
//  SubviewsContainable.swift
//

import UIKit

// MARK: - SubviewsContainable
/// Views that have a dedicated container for child subviews (e.g. UIStackView arrangedSubviews,
/// UIVisualEffectView.contentView) conform to this protocol so that `UIView.subviews(_:)` can
/// dispatch without a `switch self` type check.
public protocol SubviewsContainable {
    func addContainedSubviews(_ subviews: [UIView])
}

extension UIStackView: SubviewsContainable {
    public func addContainedSubviews(_ subviews: [UIView]) {
        views(subviews)
    }
}

extension UIVisualEffectView: SubviewsContainable {
    public func addContainedSubviews(_ subviews: [UIView]) {
        subviews.forEach { contentView.addSubview($0) }
    }
}
