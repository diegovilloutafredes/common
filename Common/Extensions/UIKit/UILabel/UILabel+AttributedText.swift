//
//  UILabel+AttributedText.swift
//

import UIKit

extension UILabel {
    
    /// Sets the attributed text and returns self (chainable).
    /// - Parameter attributedText: The attributed string to set.
    @discardableResult public func attributedText(_ attributedText: NSAttributedString?) -> Self {
        with { $0.attributedText = attributedText }
    }
}
