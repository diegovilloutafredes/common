//
//  UIPageControl+PageIndicatorTintColor.swift
//

import UIKit

extension UIPageControl {
    
    /// Sets the tint color for page indicators and returns self (chainable).
    /// - Parameter pageIndicatorTintColor: The color for non-current page indicators.
    @discardableResult public func pageIndicatorTintColor(_ pageIndicatorTintColor: UIColor) -> Self {
        with { $0.pageIndicatorTintColor = pageIndicatorTintColor }
    }
}
