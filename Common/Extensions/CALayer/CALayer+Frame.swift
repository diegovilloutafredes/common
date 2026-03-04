//
//  CALayer+Frame.swift
//

import UIKit

extension CALayer {
    
    /// Sets the frame of the layer and returns self (chainable).
    /// - Parameter frame: The new frame rectangle.
    @discardableResult
    public func frame(_ frame: CGRect) -> Self {
        with { $0.frame = frame }
    }
}
