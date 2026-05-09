//
//  UITextField+TextColor.swift
//

import UIKit

extension UITextField {
    
    /// Sets the text color and returns self (chainable).
    /// - Parameter textColor: The color to set. Defaults to `.black`.
    @discardableResult public func textColor(_ textColor: UIColor? = .black) -> Self {
        with { $0.textColor = textColor }
    }
}
