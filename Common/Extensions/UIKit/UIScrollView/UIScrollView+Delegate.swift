//
//  UIScrollView+Delegate.swift
//

import UIKit

extension UIScrollView {
    
    /// Sets the delegate and returns self (chainable).
    /// - Parameter delegate: The scroll view delegate.
    @discardableResult public func delegate(_ delegate: UIScrollViewDelegate) -> Self {
        with { $0.delegate = delegate }
    }
}
