//
//  CAShapeLayer+StrokeColor.swift
//

import UIKit

extension CAShapeLayer {
    
    /// Sets the stroke color and returns self (chainable).
    /// - Parameter strokeColor: The color to stroke the path.
    @discardableResult
    public func strokeColor(_ strokeColor: UIColor) -> Self {
        with { $0.strokeColor = strokeColor.cgColor }
    }
}
