//
//  UIPickerView+Delegate.swift
//

import UIKit

extension UIPickerView {
    
    /// Sets the delegate and returns self (chainable).
    /// - Parameter delegate: The delegate to set.
    @discardableResult public func delegate(_ delegate: UIPickerViewDelegate) -> Self {
        with { $0.delegate = delegate }
    }
}
