//
//  UITextField+TintColor.swift
//

import UIKit

extension UITextField {
    @discardableResult public func tintColor(_ tintColor: UIColor) -> Self {
        with { $0.tintColor = tintColor }
    }
}
