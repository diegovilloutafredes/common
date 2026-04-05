//
//  UIView+ClipsToBounds.swift
//

import UIKit

extension UIView {
    
    /// Sets whether subviews are clipped to bounds and returns self (chainable).
    /// - Parameter clipsToBounds: `true` to clip subviews.
    @discardableResult public func clipsToBounds(_ clipsToBounds: Bool) -> Self {
        with { $0.clipsToBounds = clipsToBounds }
    }
}
