//
//  UIApplication+SetRootViewController.swift
//

import UIKit

// MARK: - setRootViewController
// MARK: - setRootViewController
extension UIApplication {
    
    /// Sets the root view controller of the key window.
    /// - Parameter rootViewController: The view controller to set as root.
    public func set(rootViewController: UIViewController?) { keyWindow?.set(rootViewController: rootViewController) }
}
