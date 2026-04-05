//
//  UITextField+RightView.swift
//

import UIKit

extension UITextField {
    
    /// Sets the right view (always visible) and returns self (chainable).
    /// - Parameter rightView: The view to display on the right.
    @discardableResult public func rightView(_ rightView: UIView) -> Self {
        with {
            $0.rightView = rightView
            $0.rightViewMode(.always)
        }
    }
}
