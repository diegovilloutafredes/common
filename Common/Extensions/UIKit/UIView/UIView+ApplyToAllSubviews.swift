//
//  UIView+ApplyToAllSubviews.swift
//

import UIKit

extension UIView {
    
    /// Recursively applies a handler to all subviews and returns self (chainable).
    /// - Parameter handler: The handler to apply to each subview.
    @discardableResult public func applyToAllSubviews(_ handler: Handler<UIView>) -> Self {
        with {
            $0.subviews.forEach {
                handler($0)
                $0.applyToAllSubviews(handler)
            }
        }
    }
}
