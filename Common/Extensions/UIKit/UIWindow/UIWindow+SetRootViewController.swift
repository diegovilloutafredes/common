//
//  UIWindow+SetRootViewController.swift
//

import UIKit

extension UIWindow {
    public func set(rootViewController: UIViewController?) {
        self.rootViewController = rootViewController
        makeKeyAndVisible()
    }
}
