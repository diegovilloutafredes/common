//
//  UITabBar+TintColor.swift
//

import UIKit

extension UITabBar {
    
    /// Sets the tint color and returns self (chainable).
    /// - Parameter tintColor: The tint color for the tab bar.
    @discardableResult public func tintColor(_ tintColor: UIColor) -> Self {
        with { $0.tintColor = tintColor }
    }
}
