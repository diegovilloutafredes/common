//
//  UITabBarItem+Title.swift
//

import UIKit

extension UITabBarItem {
    
    /// Sets the title and returns self (chainable).
    /// - Parameter title: The title to set.
    @discardableResult public func title(_ title: String?) -> Self {
        with { $0.title = title }
    }
}
