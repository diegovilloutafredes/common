//
//  CAShapeLayer+FillRule.swift
//

import UIKit

extension CAShapeLayer {
    
    /// Sets the fill rule used when filling the path and returns self (chainable).
    /// - Parameter fillRule: The fill rule to use.
    @discardableResult
    public func fillRule(_ fillRule: CAShapeLayerFillRule) -> Self {
        with { $0.fillRule = fillRule }
    }
}
