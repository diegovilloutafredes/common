//
//  CAShapeLayer+LineWidth.swift
//

import UIKit

extension CAShapeLayer {
    
    /// Sets the line width and returns self (chainable).
    /// - Parameter lineWidth: The width of the line.
    @discardableResult
    public func lineWidth(_ lineWidth: CGFloat) -> Self {
        with { $0.lineWidth = lineWidth }
    }
}
