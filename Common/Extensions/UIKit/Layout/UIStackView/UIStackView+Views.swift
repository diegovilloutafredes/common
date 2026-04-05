//
//  UIStackView+Views.swift
//

import UIKit

extension UIStackView {
    
    /// Adds an array of views as arranged subviews and returns self (chainable).
    /// - Parameter views: The views to add.
    @discardableResult public func views(_ views: [UIView]) -> Self {
        with { sv in views.forEach { sv.addArrangedSubview($0) } }
    }

    /// Adds views from a result builder as arranged subviews and returns self (chainable).
    /// - Parameter views: A result builder closure providing the views.
    @discardableResult public func views(@UIViewsBuilder _ views: () -> [UIView]) -> Self {
        with { $0.views(views()) }
    }
}
