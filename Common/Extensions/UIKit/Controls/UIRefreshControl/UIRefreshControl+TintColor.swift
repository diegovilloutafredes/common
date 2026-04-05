//
//  UIRefreshControl+TintColor.swift
//

import UIKit

extension UIRefreshControl {
    
    /// Sets the tint color and returns self (chainable).
    /// - Parameter tintColor: The tint color for the refresh control.
    @discardableResult public func tintColor(_ tintColor: UIColor) -> Self {
        with { $0.tintColor = tintColor }
    }
}
