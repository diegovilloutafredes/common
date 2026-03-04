//
//  CAShapeLayer+LineCap.swift
//

import UIKit

extension CAShapeLayer {
    
    /// Sets the line cap style and returns self (chainable).
    /// - Parameter lineCap: The line cap style.
    @discardableResult
    public func lineCap(_ lineCap: CAShapeLayerLineCap) -> Self {
        with { $0.lineCap = lineCap }
    }
}
