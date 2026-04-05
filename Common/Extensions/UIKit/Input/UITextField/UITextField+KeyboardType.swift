//
//  UITextField+KeyboardType.swift
//

import UIKit

extension UITextField {
    
    /// Sets the keyboard type and returns self (chainable).
    /// - Parameter keyboardType: The keyboard type to set.
    @discardableResult public func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        with { $0.keyboardType = keyboardType }
    }
}
