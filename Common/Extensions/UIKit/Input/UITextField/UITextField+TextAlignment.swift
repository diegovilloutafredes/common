//
//  UITextField+TextAlignment.swift
//

import UIKit

extension UITextField {
    
    /// Sets the text alignment and returns self (chainable).
    /// - Parameter textAlignment: The alignment to set.
    @discardableResult public func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
        with { $0.textAlignment = textAlignment }
    }
}
