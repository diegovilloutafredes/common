//
//  UIStackView+Spacing.swift
//

import UIKit

extension UIStackView {
    
    /// Sets the spacing between arranged subviews and returns self (chainable).
    /// - Parameter spacing: The spacing in points.
    @discardableResult public func spacing(_ spacing: CGFloat) -> Self {
        with { $0.spacing = spacing }
    }
}
