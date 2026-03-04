//
//  CAShapeLayer+FillColor.swift
//

import UIKit

extension CAShapeLayer {
    
    /// Sets the fill color and returns self (chainable).
    /// - Parameter fillColor: The color to fill the path.
    @discardableResult
    public func fillColor(_ fillColor: UIColor) -> Self {
        with { $0.fillColor = fillColor.cgColor }
    }
}
