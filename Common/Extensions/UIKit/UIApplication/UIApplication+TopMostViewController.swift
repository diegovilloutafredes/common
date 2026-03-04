//
//  UIApplication+TopMostViewController.swift
//

import UIKit

// MARK: - Top Most ViewController
// MARK: - Top Most ViewController
extension UIApplication {
    
    /// Returns the top-most view controller in the key window's hierarchy.
    public var topMostViewController: UIViewController? { keyWindow?.rootViewController?.topMostViewController }
}
