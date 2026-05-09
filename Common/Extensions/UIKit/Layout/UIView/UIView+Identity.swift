//
//  UIView+Identity.swift
//

import UIKit

extension UIView {
    
    /// Resets the transform to identity and returns self (chainable).
    @discardableResult public func identity() -> Self {
        with { $0.transform(.identity) }
    }
}
