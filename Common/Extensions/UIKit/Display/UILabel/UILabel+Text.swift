//
//  UILabel+Text.swift
//

import UIKit

extension UILabel {
    
    /// Sets the text and returns self (chainable).
    /// - Parameter text: The text to set.
    @discardableResult public func text(_ text: String?) -> Self {
        with { $0.text = text }
    }
}
