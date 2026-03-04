//
//  UIViewController+isNotPresenting.swift
//

import UIKit

// MARK: - isNotPresenting
extension UIViewController {
    
    /// Returns `true` if this view controller is not presenting another.
    public var isNotPresenting: Bool { presentedViewController.isNil }
}
