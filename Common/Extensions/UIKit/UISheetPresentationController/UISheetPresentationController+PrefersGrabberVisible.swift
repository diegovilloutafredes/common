//
//  UISheetPresentationController+PrefersGrabberVisible.swift
//

import UIKit

extension UISheetPresentationController {
    
    /// Sets whether the grabber is visible and returns self (chainable).
    /// - Parameter prefersGrabberVisible: `true` to show the grabber.
    @discardableResult public func prefersGrabberVisible(_ prefersGrabberVisible: Bool) -> Self { with { $0.prefersGrabberVisible = prefersGrabberVisible } }
}
