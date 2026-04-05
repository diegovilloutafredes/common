//
//  UIViewController+IsPresenting.swift
//

import UIKit

// MARK: - isPresenting
extension UIViewController {
    
    /// Returns `true` if this view controller is presenting another.
    public var isPresenting: Bool { presentedViewController.isNotNil }
}
