//
//  UISwitch+IsOn.swift
//

import UIKit

extension UISwitch {
    
    /// Sets the switch state and returns self (chainable).
    /// - Parameter isOn: `true` to turn the switch on.
    @discardableResult public func isOn(_ isOn: Bool) -> Self {
        with { $0.isOn = isOn }
    }
}
