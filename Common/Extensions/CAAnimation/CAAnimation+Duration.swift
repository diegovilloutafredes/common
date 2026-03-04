//
//  CAAnimation+Duration.swift
//

import UIKit

extension CAAnimation {
    
    /// Sets the duration of the animation and returns self (chainable).
    /// - Parameter duration: The duration in seconds.
    @discardableResult
    public func duration(_ duration: TimeInterval) -> Self {
        with { $0.duration = duration }
    }
}
