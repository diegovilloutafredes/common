//
//  CABasicAnimation+ToValue.swift
//

import UIKit

extension CABasicAnimation {
    
    /// Sets the ending value of the animation and returns self (chainable).
    /// - Parameter toValue: The value to end at.
    @discardableResult
    public func toValue(_ toValue: Any) -> Self {
        with { $0.toValue = toValue }
    }
}
