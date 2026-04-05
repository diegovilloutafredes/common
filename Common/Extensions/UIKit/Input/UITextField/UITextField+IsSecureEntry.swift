//
//  UITextField+IsSecureEntry.swift
//

import UIKit

extension UITextField {
    
    /// Sets whether the text entry is secure (password) and returns self (chainable).
    /// - Parameter isSecureTextEntry: `true` to hide text. Defaults to `true`.
    @discardableResult public func isSecureTextEntry(_ isSecureTextEntry: Bool = true) -> Self {
        with { $0.isSecureTextEntry = isSecureTextEntry }
    }
}
