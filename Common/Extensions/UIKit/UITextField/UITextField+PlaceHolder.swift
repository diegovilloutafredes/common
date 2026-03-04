//
//  UITextField+Placeholder.swift
//

import UIKit

extension UITextField {
    
    /// Sets a styled placeholder and returns self (chainable).
    /// - Parameters:
    ///   - text: The placeholder text.
    ///   - color: The placeholder text color.
    ///   - font: The placeholder font.
    @discardableResult public func placeholder(_ text: String, color: UIColor, font: UIFont) -> Self {
        with {
            $0.attributedPlaceholder = .init(
                string: text,
                attributes: [
                    .font: font,
                    .foregroundColor: color
                ]
            )
        }
    }
}
