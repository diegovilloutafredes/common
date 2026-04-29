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
            if let containable = view as? SubviewsContainable {
                containable.addContainedSubviews(subviews)
            } else {
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
