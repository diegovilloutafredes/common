//
//  UITextField+LeftViewMode.swift
//

import UIKit

extension UITextField {
    
    /// Sets the left view mode and returns self (chainable).
    /// - Parameter leftViewMode: The mode for displaying the left view.
    @discardableResult public func leftViewMode(_ leftViewMode: ViewMode) -> Self {
        with { $0.leftViewMode = leftViewMode }
    }
}
