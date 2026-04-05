//
//  UIActivityIndicatorView+Animate.swift
//

import UIKit

extension UIActivityIndicatorView {
    
    /// Starts animating the activity indicator and returns self (chainable).
    @discardableResult public func animate() -> Self {
        with { $0.startAnimating() }
    }
}
