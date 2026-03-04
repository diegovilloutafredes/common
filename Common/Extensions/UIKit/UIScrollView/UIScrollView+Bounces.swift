//
//  UIScrollView+Bounces.swift
//

import UIKit

extension UIScrollView {
    
    /// Sets whether the scroll view bounces and returns self (chainable).
    /// - Parameter bounces: `true` to enable bouncing.
    @discardableResult public func bounces(_ bounces: Bool) -> Self {
        with { $0.bounces = bounces }
    }
}
