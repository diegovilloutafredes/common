//
//  UIAlertController+AddAction.swift
//

import UIKit

extension UIAlertController {
    
    /// Adds an action to the alert controller and returns self (chainable).
    /// - Parameter action: The alert action to add.
    @discardableResult public func add(_ action: UIAlertAction) -> Self {
        with { $0.addAction(action) }
    }
}
