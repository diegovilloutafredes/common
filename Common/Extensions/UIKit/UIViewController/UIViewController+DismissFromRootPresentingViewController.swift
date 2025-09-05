//
//  UIViewController+DismissFromRootPresentingViewController.swift
//

import UIKit

// MARK: - Dismiss From Root Presenting ViewController
extension UIViewController {
    public func dismissFromRootPresentingViewController(animated: Bool = true, completion: CompletionHandler = nil) {
        isPresented ?
        presentingViewController?.dismissFromRootPresentingViewController(animated: animated, completion: completion) :
        dismiss(animated: animated, completion: completion)
    }
}
