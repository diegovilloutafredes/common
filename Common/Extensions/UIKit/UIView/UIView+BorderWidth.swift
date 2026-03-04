//
//  UIView+BorderWidth.swift
//

import UIKit

extension UIView {
    
    /// Sets the border width and returns self (chainable).
    /// - Parameter borderWidth: The border width in points.
    @discardableResult public func borderWidth(_ borderWidth: CGFloat) -> Self {
        with { $0.layer.borderWidth = borderWidth }
    }
}
