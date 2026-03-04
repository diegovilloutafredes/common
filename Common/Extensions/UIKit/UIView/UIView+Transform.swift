//
//  UIView+Transform.swift
//

import UIKit

extension UIView {
    
    /// Sets the transform and returns self (chainable).
    /// - Parameter transform: The affine transform to apply.
    @discardableResult public func transform(_ transform: CGAffineTransform) -> Self {
        with { $0.transform = transform }
    }
}
