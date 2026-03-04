//
//  NSLayoutConstraint+Constant.swift
//

import UIKit

extension NSLayoutConstraint {
    
    /// Sets the constant of the constraint and returns self (chainable).
    /// - Parameter constant: The new constant value.
    @discardableResult public func constant(_ constant: Double) -> Self {
        with { $0.constant = constant }
    }
}
