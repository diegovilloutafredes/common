//
//  UIViewController+DismissTopMostPresentedViewController.swift
//

import UIKit

// MARK: - Dismiss Top Most Presented ViewController
extension UIViewController {
    public func dismissTopMostPresentedViewController(animated: Bool = true, completion: CompletionHandler = nil) {
        topMostPresentedViewController === self ? completion?() : topMostPresentedViewController.dismiss(animated: animated, completion: completion)
    }
}
