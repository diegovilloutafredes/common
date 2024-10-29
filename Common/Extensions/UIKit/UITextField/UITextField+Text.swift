//
//  UITextField+Text.swift
//

import UIKit

extension UITextField {
    @discardableResult public func text(_ text: String?) -> Self {
        with { $0.text = text }
    }
}
