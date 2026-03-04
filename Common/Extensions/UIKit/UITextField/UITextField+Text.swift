//
//  UITextField+Text.swift
//

import UIKit

extension UITextField {
    
    /// Sets the text and returns self (chainable).
    /// - Parameter text: The text to set.
    @discardableResult public func text(_ text: String?) -> Self {
        with { $0.text = text }
    }
}
