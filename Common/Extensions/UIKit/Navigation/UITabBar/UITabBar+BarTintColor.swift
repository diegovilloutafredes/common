//
//  UITabBar+BarTintColor.swift
//

import UIKit

extension UITabBar {
    
    /// Sets the bar tint color and returns self (chainable).
    /// - Parameter barTintColor: The background tint color for the tab bar.
    @discardableResult func barTintColor(_ barTintColor: UIColor) -> Self {
        with { $0.barTintColor = barTintColor }
    }
}
