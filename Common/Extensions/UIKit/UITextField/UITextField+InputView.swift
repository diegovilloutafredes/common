//
//  UITextField+InputView.swift
//

import UIKit

extension UITextField {
    
    /// Sets the input view and returns self (chainable).
    /// - Parameter inputView: The view to use as input (e.g., a picker).
    @discardableResult public func inputView(_ inputView: UIView) -> Self {
        with { $0.inputView = inputView }
    }
}
