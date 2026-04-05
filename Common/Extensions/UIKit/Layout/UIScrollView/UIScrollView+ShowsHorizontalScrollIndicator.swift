//
//  UIScrollView+ShowsHorizontalScrollIndicator.swift
//

import UIKit

extension UIScrollView {
    
    /// Sets whether to show the horizontal scroll indicator and returns self (chainable).
    /// - Parameter showsHorizontalScrollIndicator: `true` to show the indicator.
    @discardableResult public func showsHorizontalScrollIndicator(_ showsHorizontalScrollIndicator: Bool) -> Self {
        with { $0.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator }
    }
}
