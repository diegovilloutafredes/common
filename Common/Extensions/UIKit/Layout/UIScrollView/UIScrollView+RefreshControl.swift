//
//  UIScrollView+RefreshControl.swift
//

import UIKit

extension UIScrollView {
    
    /// Sets the refresh control and returns self (chainable).
    /// - Parameter refreshControl: The refresh control to set.
    @discardableResult public func refreshControl(_ refreshControl: UIRefreshControl) -> Self {
        with { $0.refreshControl = refreshControl }
    }
}
