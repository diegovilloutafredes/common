//
//  UITabBarController+Init.swift
//

import UIKit

extension UITabBarController {
    
    /// Initializes a tab bar controller with view controllers from a result builder.
    /// - Parameter viewControllers: A result builder closure providing the view controllers.
    convenience public init(@ArrayBuilder<UIViewController> _ viewControllers: () -> [UIViewController] = {[]}) {
        self.init(nibName: nil, bundle: nil)
        setViewControllers(viewControllers(), animated: false)
    }
}
