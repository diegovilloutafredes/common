//
//  UISwitch+isOff.swift
//

import UIKit

extension UISwitch {
    @discardableResult public func isOn(_ isOn: Bool) -> Self {
        with { $0.isOn = isOn }
    }
}
