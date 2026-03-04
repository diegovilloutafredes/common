//
//  UILabel+TextAlignment.swift
//

import UIKit

extension UILabel {
    
    /// Sets the text alignment and returns self (chainable).
    /// - Parameter textAlignment: The alignment to set. Defaults to `.left`.
    @discardableResult public func textAlignment(_ textAlignment: NSTextAlignment? = .left) -> Self {
        with { $0.textAlignment = textAlignment! }
    }
}
