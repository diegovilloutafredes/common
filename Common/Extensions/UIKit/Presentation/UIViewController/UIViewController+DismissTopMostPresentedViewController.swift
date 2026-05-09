//
//  UIViewController+DismissTopMostPresentedViewController.swift
//

import UIKit

// MARK: - Dismiss Top Most Presented ViewController
extension UIViewController {
    
    /// Dismisses the top most presented view controller.
    /// - Parameters:
    ///   - animated: Whether to animate. Defaults to `true`.
    ///   - completion: Completion handler.
    public func dismissTopMostPresentedViewController(animated: Bool = true, completion: CompletionHandler = nil) {
        topMostPresentedViewController === self ?
        completion?() :
        topMostPresentedViewController.dismiss(animated: animated, completion: completion)
    }
}
