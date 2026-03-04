//
//  UITextField+Font.swift
//

import UIKit

extension UITextField {
    
    /// Sets the font and returns self (chainable).
    /// - Parameter font: The font to set.
    @discardableResult public func font(_ font: UIFont) -> Self {
        with { $0.font = font }
    }
}
