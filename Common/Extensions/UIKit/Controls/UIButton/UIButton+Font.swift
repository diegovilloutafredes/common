//
//  UIButton+Font.swift
//

import UIKit

extension UIButton {
    
    /// Sets the font of the title label and returns self (chainable).
    /// - Parameter font: The font to set.
    @discardableResult public func font(_ font: UIFont) -> Self {
        with { $0.titleLabel?.font(font) }
    }
}
