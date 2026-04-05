//
//  UIWindow+SetRootViewController.swift
//

import UIKit

extension UIWindow {
    
    /// Sets the root view controller and makes the window key and visible.
    /// - Parameter rootViewController: The view controller to set as root.
    public func set(rootViewController: UIViewController?) {
        self.rootViewController = rootViewController
        makeKeyAndVisible()
    }
}
