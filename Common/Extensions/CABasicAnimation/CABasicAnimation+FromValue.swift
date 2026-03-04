//
//  CABasicAnimation+FromValue.swift
//

import UIKit

extension CABasicAnimation {
    
    /// Sets the starting value of the animation and returns self (chainable).
    /// - Parameter fromValue: The value to start from.
    @discardableResult
    public func fromValue(_ fromValue: Any) -> Self {
        with { $0.fromValue = fromValue }
    }
}
