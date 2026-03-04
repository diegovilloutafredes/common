//
//  CAShapeLayer+StrokeEnd.swift
//

import UIKit

extension CAShapeLayer {
    
    /// Sets the stroke end value (fraction of the path to stroke) and returns self (chainable).
    /// - Parameter strokeEnd: The value between 0.0 and 1.0.
    @discardableResult
    public func strokeEnd(_ strokeEnd: CGFloat) -> Self {
        with { $0.strokeEnd = strokeEnd }
    }
}
