//
//  UIScrollView+KeyboardDismissMode.swift
//

import UIKit

extension UIScrollView {
    
    /// Sets the keyboard dismiss mode and returns self (chainable).
    /// - Parameter keyboardDismissMode: The mode for dismissing the keyboard.
    @discardableResult public func keyboardDismissMode(_ keyboardDismissMode: KeyboardDismissMode) -> Self {
        with { $0.keyboardDismissMode = keyboardDismissMode }
    }
}
