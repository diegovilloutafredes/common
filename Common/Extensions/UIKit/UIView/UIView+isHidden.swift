//
//  UIView+isHidden.swift
//

import UIKit

extension UIView {
    
    /// Sets whether the view is hidden and returns self (chainable).
    /// - Parameter isHidden: `true` to hide the view.
    @discardableResult public func isHidden(_ isHidden: Bool) -> Self {
        with { $0.isHidden = isHidden }
    }
}
