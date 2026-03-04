//
//  CAShapeLayer+Path.swift
//

import UIKit

extension CAShapeLayer {
    
    /// Sets the path and returns self (chainable).
    /// - Parameter path: The path to be rendered.
    @discardableResult
    public func path(_ path: CGPath) -> Self {
        with { $0.path = path }
    }
}
