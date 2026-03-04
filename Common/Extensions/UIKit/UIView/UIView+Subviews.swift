//
//  UIView+Subviews.swift
//

import UIKit

// MARK: - Subviews
extension UIView {
    
    /// Adds subviews and returns self (chainable).
    /// - Parameter subviews: The subviews to add.
    @discardableResult public func subviews(_ subviews: [UIView]) -> Self {
        with { view in
            switch self {
            case is UIStackView:
                (view as! UIStackView).views(subviews)
            case is UIVisualEffectView:
                subviews.forEach { (view as! UIVisualEffectView).contentView.addSubview($0) }
            default:
                subviews.forEach { view.addSubview($0) }
            }
        }
    }

    /// Adds subviews using a result builder and returns self (chainable).
    /// - Parameter subviews: A result builder closure providing the subviews.
    @discardableResult public func subviews(@UIViewsBuilder _ subviews: () -> [UIView] = {[]}) -> Self {
        with { $0.subviews(subviews()) }
    }
}
