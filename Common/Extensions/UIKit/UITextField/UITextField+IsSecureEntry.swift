//
//  UITextField+IsSecureEntry.swift
//

import UIKit

extension UITextField {
    @discardableResult public func isSecureTextEntry(_ isSecureTextEntry: Bool = true) -> Self {
        with { $0.isSecureTextEntry = isSecureTextEntry }
    }
}
