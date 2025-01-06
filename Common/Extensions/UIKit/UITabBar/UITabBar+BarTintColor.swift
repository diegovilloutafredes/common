//
//  UITabBar+BarTintColor.swift
//

import UIKit

extension UITabBar {
    @discardableResult func barTintColor(_ barTintColor: UIColor) -> Self {
        with { $0.barTintColor = barTintColor }
    }
}
