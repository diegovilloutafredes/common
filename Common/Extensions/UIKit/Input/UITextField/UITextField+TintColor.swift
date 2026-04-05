//
//  UITextField+TintColor.swift
//

import UIKit

extension UITextField {
    
    /// Sets the tint color and returns self (chainable).
    /// - Parameter tintColor: The tint color to set.
    @discardableResult public func tintColor(_ tintColor: UIColor) -> Self {
        with { $0.tintColor = tintColor }
    }
}
