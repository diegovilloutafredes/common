//
//  UITabBar+UnselectedItemTintColor.swift
//

import UIKit

extension UITabBar {
    
    /// Sets the unselected item tint color and returns self (chainable).
    /// - Parameter unselectedItemTintColor: The color for unselected tab bar items.
    @discardableResult public func unselectedItemTintColor(_ unselectedItemTintColor: UIColor) -> Self {
        with { $0.unselectedItemTintColor = unselectedItemTintColor }
    }
}
