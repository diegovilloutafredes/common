//
//  UIView+Alpha.swift
//

import UIKit

extension UIView {
    
    /// Sets the alpha value and returns self (chainable).
    /// - Parameter alpha: The alpha value (0.0 to 1.0).
    @discardableResult public func alpha(_ alpha: CGFloat) -> Self {
        with { $0.alpha = alpha }
    }
}
