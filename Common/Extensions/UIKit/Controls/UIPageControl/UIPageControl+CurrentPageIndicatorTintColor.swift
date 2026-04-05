//
//  UIPageControl+CurrentPageIndicatorTintColor.swift
//

import UIKit

extension UIPageControl {
    
    /// Sets the tint color for the current page indicator and returns self (chainable).
    /// - Parameter currentPageIndicatorTintColor: The color for the current page indicator.
    @discardableResult public func currentPageIndicatorTintColor(_ currentPageIndicatorTintColor: UIColor) -> Self {
        with { $0.currentPageIndicatorTintColor = currentPageIndicatorTintColor }
    }
}
