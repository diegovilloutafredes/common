//
//  UIStackView+Axis.swift
//

import UIKit

extension UIStackView {
    
    /// Sets the axis and returns self (chainable).
    /// - Parameter axis: The axis (horizontal or vertical) to set.
    @discardableResult public func axis(_ axis: NSLayoutConstraint.Axis) -> Self {
        with { $0.axis = axis }
    }
}
