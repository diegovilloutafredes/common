//
//  UIPageControl+NumberOfPages.swift
//

import UIKit

extension UIPageControl {
    
    /// Sets the number of pages and returns self (chainable).
    /// - Parameter numberOfPages: The total number of pages.
    @discardableResult public func numberOfPages(_ numberOfPages: Int) -> Self {
        with { $0.numberOfPages = numberOfPages }
    }
}
