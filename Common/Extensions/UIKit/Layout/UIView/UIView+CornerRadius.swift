//
//  UIView+CornerRadius.swift
//

import UIKit

extension UIView {
    
    /// Sets the corner radius and returns self (chainable).
    /// - Parameter cornerRadius: The corner radius in points.
    @discardableResult public func cornerRadius(_ cornerRadius: CGFloat) -> Self {
        with { $0.layer.cornerRadius = cornerRadius }
    }
}
