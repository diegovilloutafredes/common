//
//  UIViewController+ClosestParentViewController.swift
//

import UIKit

// MARK: - Closest Parent ViewController
extension UIViewController {
    public func closestParentViewController(class someClass: AnyClass) -> UIViewController? {
        var viewController: UIViewController? = self

        while let someViewController = viewController {
            if someViewController.isKind(of: someClass) { return someViewController }
            viewController = someViewController.parent
        }

        return nil
    }
}
