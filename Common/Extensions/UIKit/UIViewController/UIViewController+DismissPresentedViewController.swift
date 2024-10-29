//
//  UIViewController+DismissPresentedViewController.swift
//

import UIKit

// MARK: - Dismiss Presented ViewController
extension UIViewController {
    public func dismissPresentedViewController(animated: Bool = true, completion: CompletionHandler = nil) {
        Logger.log(["Attempting to dismiss from": self])
        guard
            isPresenting,
            let presentedViewController
        else {
            guard isBeingPresented else { completion?(); return }
            Logger.log(["\(Self.self)": self])
            dismiss(animated: animated, completion: completion)
            return
        }

        guard presentedViewController.isPresenting else {
            Logger.log(["\(Self.self)": presentedViewController])
            presentedViewController.dismiss(animated: animated, completion: completion)
            return
        }

        presentedViewController.dismissPresentedViewController(animated: animated, completion: completion)
    }
}
