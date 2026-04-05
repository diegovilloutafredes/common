//
//  UIScrollView+IsPagingEnabled.swift
//

import UIKit

extension UIScrollView {
    
    /// Sets whether paging is enabled and returns self (chainable).
    /// - Parameter isPagingEnabled: `true` to enable paging.
    @discardableResult public func isPagingEnabled(_ isPagingEnabled: Bool) -> Self {
        with { $0.isPagingEnabled = isPagingEnabled }
    }
}
