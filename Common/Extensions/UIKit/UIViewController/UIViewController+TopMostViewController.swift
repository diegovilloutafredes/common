//
//  UIViewController+TopMostViewController.swift
//

import UIKit

// MARK: - Top Most ViewController
extension UIViewController {
    public var topMostViewController: UIViewController {
        if let presentedViewController { return presentedViewController.topMostViewController }
        if let navigationController = self as? UINavigationController { return navigationController.visibleViewController?.topMostViewController ?? navigationController }
        if let tabBarController = self as? UITabBarController { return tabBarController.selectedViewController?.topMostViewController ?? tabBarController }
        return self
    }
}
