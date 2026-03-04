//
//  UISwitch+OnColor.swift
//

import UIKit

extension UISwitch {
    
    /// Sets the on tint color and returns self (chainable).
    /// - Parameter color: The color when the switch is on.
    @discardableResult public func on(_ color: UIColor) -> Self {
        with { $0.onTintColor = color }
    }
}
