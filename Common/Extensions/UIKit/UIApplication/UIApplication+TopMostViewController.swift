//
//  UIApplication+TopMostViewController.swift
//

import UIKit

// MARK: - Top Most ViewController
extension UIApplication {
    public var topMostViewController: UIViewController? { keyWindow?.rootViewController?.topMostViewController }
}
