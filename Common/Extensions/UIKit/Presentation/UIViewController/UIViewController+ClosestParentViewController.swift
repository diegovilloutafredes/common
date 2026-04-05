//
//  UIViewController+ClosestParentViewController.swift
//

import UIKit

// MARK: - Closest Parent ViewController
extension UIViewController {
    
    /// Finds the closest parent view controller of a specific class.
    /// - Parameter someClass: The class type to search for.
    /// - Returns: The matching parent view controller, or nil.
    public func closestParentViewController(class someClass: AnyClass) -> UIViewController? {
        var viewController: UIViewController? = self

        while let someViewController = viewController {
            if someViewController.isKind(of: someClass) { return someViewController }
            viewController = someViewController.parent
        }

        return nil
    }
}
