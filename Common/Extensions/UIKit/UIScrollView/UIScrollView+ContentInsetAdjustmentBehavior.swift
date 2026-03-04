//
//  UIScrollView+ContentInsetAdjustmentBehavior.swift
//

import UIKit

extension UIScrollView {
    
    /// Sets the content inset adjustment behavior and returns self (chainable).
    /// - Parameter contentInsetAdjustmentBehavior: The adjustment behavior to set.
    @discardableResult public func contentInsetAdjustmentBehavior(_ contentInsetAdjustmentBehavior: ContentInsetAdjustmentBehavior) -> Self {
        with { $0.contentInsetAdjustmentBehavior = contentInsetAdjustmentBehavior }
    }
}
