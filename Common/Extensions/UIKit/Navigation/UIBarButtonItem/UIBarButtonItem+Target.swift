//
//  UIBarButtonItem+Target.swift
//

import UIKit

extension UIBarButtonItem {
    
    /// Sets the target object and returns self (chainable).
    /// - Parameter target: The target object.
    @discardableResult public func target(_ target: AnyObject?) -> Self {
        with { $0.target = target }
    }
}
