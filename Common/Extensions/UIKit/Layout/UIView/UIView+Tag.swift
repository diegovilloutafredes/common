//
//  UIView+Tag.swift
//

import UIKit

extension UIView {
    
    /// Sets the tag and returns self (chainable).
    /// - Parameter tag: The tag identifier.
    @discardableResult public func tag(_ tag: Int) -> Self {
        with { $0.tag = tag }
    }
}
