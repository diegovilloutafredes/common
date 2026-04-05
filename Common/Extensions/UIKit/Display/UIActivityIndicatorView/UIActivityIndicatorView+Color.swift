//
//  UIActivityIndicatorView+Color.swift
//

import UIKit

extension UIActivityIndicatorView {
    
    /// Sets the color of the activity indicator and returns self (chainable).
    /// - Parameter color: The color to set.
    @discardableResult public func color(_ color: UIColor) -> Self {
        with { $0.color = color }
    }
}
