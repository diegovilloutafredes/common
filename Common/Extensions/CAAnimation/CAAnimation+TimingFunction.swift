//
//  CAAnimation+TimingFunction.swift
//

import UIKit

extension CAAnimation {
    
    /// Sets the timing function of the animation and returns self (chainable).
    /// - Parameter timingFunction: The timing function to use.
    @discardableResult
    public func timingFunction(_ timingFunction: CAMediaTimingFunction) -> Self {
        with { $0.timingFunction = timingFunction }
    }
}
