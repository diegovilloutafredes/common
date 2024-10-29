//
//  UITextField+KeyboardType.swift
//

import UIKit

extension UITextField {
    @discardableResult public func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        with { $0.keyboardType = keyboardType }
    }
}
