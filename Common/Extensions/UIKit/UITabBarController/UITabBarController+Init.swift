//
//  UITabBarController+Init.swift
//

import UIKit

extension UITabBarController {
    convenience public init(@ArrayBuilder<UIViewController> _ viewControllers: () -> [UIViewController] = {[]}) {
        self.init(nibName: nil, bundle: nil)
        setViewControllers(viewControllers(), animated: false)
    }
}
