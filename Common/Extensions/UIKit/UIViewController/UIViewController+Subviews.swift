//
//  UIViewController+Subviews.swift
//

import UIKit

// MARK: - Subviews
extension UIViewController {
    
    /// Adds subviews to the view controller's view and returns self (chainable).
    /// - Parameter subviews: The subviews to add.
    @discardableResult public func subviews(_ subviews: [UIView]) -> Self {
        with { $0.view.subviews(subviews) }
    }

    /// Adds subviews using a result builder and returns self (chainable).
    /// - Parameter subviews: A result builder closure providing the subviews.
    @discardableResult public func subviews(@UIViewsBuilder _ subviews: () -> [UIView]) -> Self {
        with { $0.subviews(subviews()) }
    }
}
