//
//  UIView+BringSelfToFront.swift
//

import UIKit

extension UIView {
    
    /// Brings this view to the front in its superview and returns self (chainable).
    @discardableResult public func bringSelfToFront() -> Self {
        with { $0.superview?.bringToFront($0) }
    }
}
