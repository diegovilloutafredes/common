//
//  UIViewController+TopMostPresentedViewController.swift
//

import UIKit

// MARK: - Top Most Presented ViewController
extension UIViewController {
    
    /// Returns the top most presented view controller in the presentation chain.
    public var topMostPresentedViewController: UIViewController { presentedViewController?.topMostPresentedViewController ?? self }
}
