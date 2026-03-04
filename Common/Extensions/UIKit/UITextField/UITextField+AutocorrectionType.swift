//
//  UITextField+AutocorrectionType.swift
//

import UIKit

extension UITextField {
    
    /// Sets the autocorrection type and returns self (chainable).
    /// - Parameter autocorrectionType: The autocorrection type to set.
    @discardableResult public func autocorrectionType(_ autocorrectionType: UITextAutocorrectionType) -> Self {
        with { $0.autocorrectionType = autocorrectionType }
    }
}
