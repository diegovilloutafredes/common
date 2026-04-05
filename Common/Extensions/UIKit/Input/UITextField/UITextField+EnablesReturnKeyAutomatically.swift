//
//  UITextField+EnablesReturnKeyAutomatically.swift
//

import UIKit

extension UITextField {
    
    /// Sets whether the return key is automatically enabled and returns self (chainable).
    /// - Parameter enablesReturnKeyAutomatically: `true` to enable automatically when text is present.
    @discardableResult public func enablesReturnKeyAutomatically(_ enablesReturnKeyAutomatically: Bool) -> Self {
        with { $0.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically }
    }
}
