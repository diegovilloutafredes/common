//
//  UIScrollView+IsScrollEnabled.swift
//

import UIKit

extension UIScrollView {
    
    /// Sets whether scrolling is enabled and returns self (chainable).
    /// - Parameter isScrollEnabled: `true` to enable scrolling.
    @discardableResult public func isScrollEnabled(_ isScrollEnabled: Bool) -> Self {
        with { $0.isScrollEnabled = isScrollEnabled }
    }
}
