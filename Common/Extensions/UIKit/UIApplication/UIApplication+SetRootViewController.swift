//
//  UIApplication+SetRootViewController.swift
//

import UIKit

// MARK: - setRootViewController
extension UIApplication {
    public func set(rootViewController: UIViewController?) { keyWindow?.set(rootViewController: rootViewController) }
}
