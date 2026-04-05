//
//  UITextField+LeftView.swift
//

import UIKit

extension UITextField {
    
    /// Sets the left view (always visible) and returns self (chainable).
    /// - Parameter leftView: The view to display on the left.
    @discardableResult public func leftView(_ leftView: UIView) -> Self {
        with {
            $0.leftView = leftView
            $0.leftViewMode(.always)
        }
    }
}
