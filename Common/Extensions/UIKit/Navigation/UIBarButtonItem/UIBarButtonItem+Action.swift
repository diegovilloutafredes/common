//
//  UIBarButtonItem+Action.swift
//

import UIKit

extension UIBarButtonItem {
    
    /// Sets the action selector and returns self (chainable).
    /// - Parameter action: The selector to be called on action.
    @discardableResult public func action(_ action: Selector?) -> Self {
        with { $0.action = action }
    }
}
