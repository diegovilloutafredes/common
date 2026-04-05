//
//  UIControl+IsEnabled.swift
//

import UIKit

extension UIControl {
    
    /// Sets whether the control is enabled and returns self (chainable).
    /// - Parameter isEnabled: `true` to enable, `false` to disable.
    @discardableResult public func isEnabled(_ isEnabled: Bool) -> Self {
        with { $0.isEnabled = isEnabled }
    }
}
