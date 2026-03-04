//
//  UIScrollView+ShowsVerticalScrollIndicator.swift
//

import UIKit

extension UIScrollView {
    
    /// Sets whether to show the vertical scroll indicator and returns self (chainable).
    /// - Parameter showsVerticalScrollIndicator: `true` to show the indicator.
    @discardableResult public func showsVerticalScrollIndicator(_ showsVerticalScrollIndicator: Bool) -> Self {
        with { $0.showsVerticalScrollIndicator = showsVerticalScrollIndicator }
    }
}
