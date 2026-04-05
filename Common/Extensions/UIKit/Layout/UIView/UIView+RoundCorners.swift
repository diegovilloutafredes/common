//
//  UIView+RoundCorners.swift
//

import UIKit

// MARK: - UIView+RoundCorners
extension UIView {
    
    /// Rounds specified corners with a radius and returns self (chainable).
    /// - Parameters:
    ///   - corners: The corners to round. Defaults to `.all`.
    ///   - radius: The corner radius. Defaults to system value.
    @discardableResult public func round(corners: CACornerMask = .all, radius: CGFloat = .DefaultValues.View.cornerRadius) -> Self {
        with {
            $0
                .cornerRadius(radius)
                .maskedCorners(corners)
        }
    }
}
