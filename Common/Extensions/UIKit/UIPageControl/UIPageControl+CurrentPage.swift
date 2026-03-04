//
//  UIPageControl+CurrentPage.swift
//

import UIKit

extension UIPageControl {
    
    /// Sets the current page and returns self (chainable).
    /// - Parameter currentPage: The page index to set as current.
    @discardableResult public func currentPage(_ currentPage: Int) -> Self {
        with { $0.currentPage = currentPage }
    }
}
