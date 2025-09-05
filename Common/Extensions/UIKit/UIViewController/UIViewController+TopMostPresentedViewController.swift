//
//  UIViewController+TopMostPresentedViewController.swift
//

import UIKit

// MARK: - Top Most Presented ViewController
extension UIViewController {
    public var topMostPresentedViewController: UIViewController { presentedViewController?.topMostPresentedViewController ?? self }
}
