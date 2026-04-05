//
//  UITextField+AutocapitalizationType.swift
//

import UIKit

extension UITextField {
    
    /// Sets the autocapitalization type and returns self (chainable).
    /// - Parameter autocapitalizationType: The autocapitalization type to set.
    @discardableResult public func autocapitalizationType(_ autocapitalizationType: UITextAutocapitalizationType) -> Self {
        with { $0.autocapitalizationType = autocapitalizationType }
    }
}
