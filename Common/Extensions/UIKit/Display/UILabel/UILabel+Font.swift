//
//  UILabel+Font.swift
//

import UIKit

extension UILabel {
    
    /// Sets the font and returns self (chainable).
    /// - Parameter font: The font to set. Defaults to system font size 14.
    @discardableResult public func font(_ font: UIFont = .systemFont(ofSize: 14)) -> Self {
        with { $0.font = font }
    }
}
