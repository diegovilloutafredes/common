//
//  UISwitch+OffColor.swift
//

import UIKit

extension UISwitch {
    
    /// Sets the off color (background color) and returns self (chainable).
    /// - Parameter color: The color when the switch is off.
    @discardableResult public func off(_ color: UIColor) -> Self {
        backgroundColor(color)
    }
}
