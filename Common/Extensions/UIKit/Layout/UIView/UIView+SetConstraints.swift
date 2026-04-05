//
//  UIView+SetConstraints.swift
//

import UIKit

// MARK: - Set Constraints
extension UIView {
    
    /// Sets constraints when the view moves to a superview and returns self (chainable).
    /// - Parameter setConstraints: The handler to set constraints.
    @discardableResult public func setConstraints(_ setConstraints: @escaping ViewHandler) -> Self { onMoveToSuperview(setConstraints) }
    
    /// Sets constraints when the view moves to a superview and returns self (chainable).
    /// - Parameter setConstraints: The handler with view and superview.
    @discardableResult public func setConstraints(_ setConstraints: @escaping ViewAndSuperviewHandler) -> Self { onMoveToSuperview(setConstraints) }
}
