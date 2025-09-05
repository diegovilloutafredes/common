//
//  UITabBarItem+Title.swift
//

import UIKit

extension UITabBarItem {
    @discardableResult public func title(_ title: String?) -> Self {
        with { $0.title = title }
    }
}
