//
//  UITabBarItem.swift
//

import UIKit

extension UITabBarItem {
    @discardableResult public func image(_ image: UIImage?) -> Self {
        with { $0.image = image }
    }
}
