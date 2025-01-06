//
//  UITabBar+UnselectedItemTintColor.swift
//

import UIKit

extension UITabBar {
    @discardableResult public func unselectedItemTintColor(_ unselectedItemTintColor: UIColor) -> Self {
        with { $0.unselectedItemTintColor = unselectedItemTintColor }
    }
}
