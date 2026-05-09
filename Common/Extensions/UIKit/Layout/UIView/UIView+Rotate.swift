//
//  UIView+Rotate.swift
//

import UIKit

extension UIView {
    
    /// Rotates the view and returns self (chainable).
    /// - Parameter rotationAngle: The rotation angle in radians. Defaults to `0`.
    @discardableResult public func rotate(_ rotationAngle: Double = .zero) -> Self {
        with { $0.transform(.init(rotationAngle: rotationAngle)) }
    }
}
