//
//  UISwitch+OnColor.swift
//

import UIKit

extension UISwitch {
    @discardableResult public func on(_ color: UIColor) -> Self {
        with { $0.onTintColor = color }
    }
}
