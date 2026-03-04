//
//  UIViewController+HidesBackButton.swift
//

import UIKit

extension UIViewController {
    
    /// Hides or shows the back button and returns self (chainable).
    /// - Parameters:
    ///   - hidesBackButton: `true` to hide the back button.
    ///   - animated: Whether to animate.
    @discardableResult public func hidesBackButton(_ hidesBackButton: Bool, animated: Bool = false) -> Self {
        with { $0.navigationItem.setHidesBackButton(hidesBackButton, animated: animated) }
    }
}
