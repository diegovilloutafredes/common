//
//  UIView+BringToFront.swift
//

import UIKit

extension UIView {
    
    /// Brings a subview to the front and returns self (chainable).
    /// - Parameter subview: The subview to bring to front.
    @discardableResult public func bringToFront(_ subview: UIView) -> Self {
        with { $0.bringSubviewToFront(subview) }
    }
}
