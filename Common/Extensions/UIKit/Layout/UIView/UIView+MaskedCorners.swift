//
//  UIView+MaskedCorners.swift
//

import UIKit

extension UIView {
    
    /// Sets which corners are masked and returns self (chainable).
    /// - Parameter maskedCorners: The corners to mask.
    @discardableResult public func maskedCorners(_ maskedCorners: CACornerMask) -> Self {
        with { $0.layer.maskedCorners = maskedCorners }
    }
}
