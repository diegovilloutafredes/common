//
//  UIView+AddSublayer.swift
//

import UIKit

extension UIView {
    
    /// Adds a sublayer to the view's layer and returns self (chainable).
    /// - Parameter layer: The layer to add.
    @discardableResult
    public func addSublayer(_ layer: CALayer) -> Self {
        with { $0.layer.addSublayer(layer) }
    }
}
