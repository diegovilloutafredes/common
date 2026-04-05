//
//  UIScrollView+AlwaysBounceVertical.swift
//

import UIKit

extension UIScrollView {
    
    /// Sets whether the scroll view always bounces vertically and returns self (chainable).
    /// - Parameter alwaysBounceVertical: `true` to always bounce vertically.
    @discardableResult public func alwaysBounceVertical(_ alwaysBounceVertical: Bool) -> Self {
        with { $0.alwaysBounceVertical = alwaysBounceVertical }
    }
}
