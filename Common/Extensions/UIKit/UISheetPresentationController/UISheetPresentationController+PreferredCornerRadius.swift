//
//  UISheetPresentationController+PreferredCornerRadius.swift
//

import UIKit

extension UISheetPresentationController {
    
    /// Sets the preferred corner radius and returns self (chainable).
    /// - Parameter preferredCornerRadius: The corner radius in points.
    @discardableResult public func preferredCornerRadius(_ preferredCornerRadius: CGFloat) -> Self { with { $0.preferredCornerRadius = preferredCornerRadius } }
}
