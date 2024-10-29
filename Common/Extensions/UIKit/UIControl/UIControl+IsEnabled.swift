//
//  UIControl+IsEnabled.swift
//

import UIKit

extension UIControl {
    @discardableResult public func isEnabled(_ isEnabled: Bool) -> Self {
        with { $0.isEnabled = isEnabled }
    }
}
