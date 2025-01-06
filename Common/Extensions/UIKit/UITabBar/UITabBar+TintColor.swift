//
//  UITabBar+TintColor.swift
//

import UIKit

extension UITabBar {
    @discardableResult public func tintColor(_ tintColor: UIColor) -> Self {
        with { $0.tintColor = tintColor }
    }
}
