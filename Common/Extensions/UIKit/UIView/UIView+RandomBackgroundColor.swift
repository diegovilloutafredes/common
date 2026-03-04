//
//  UIView+.swift
//

import UIKit

extension UIView {
    
    /// Sets a random background color and returns self (chainable).
    @discardableResult public func randomBackgroundColor() -> Self {
        with { $0.backgroundColor(.randomColor) }
    }
}
