//
//  UISwitch+OffColor.swift
//

import UIKit

extension UISwitch {
    @discardableResult public func off(_ color: UIColor) -> Self {
        backgroundColor(color)
    }
}
