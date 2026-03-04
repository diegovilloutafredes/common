//
//  UIViewController+DismissFromRootPresentingViewController.swift
//

import UIKit

// MARK: - Dismiss From Root Presenting ViewController
extension UIViewController {
    
    /// Dismisses from the root presenting view controller.
    /// - Parameters:
    ///   - animated: Whether to animate. Defaults to `true`.
    ///   - completion: Completion handler.
    public func dismissFromRootPresentingViewController(animated: Bool = true, completion: CompletionHandler = nil) {
        isPresented ?
        presentingViewController?.dismissFromRootPresentingViewController(animated: animated, completion: completion) :
        dismiss(animated: animated, completion: completion)
    }
}
