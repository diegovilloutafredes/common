//
//  UIView+BorderColor.swift
//

import UIKit

extension UIView {
    
    /// Sets the border color and returns self (chainable).
    /// - Parameter borderColor: The border color to set.
    @discardableResult public func borderColor(_ borderColor: UIColor) -> Self {
        with { $0.layer.borderColor = borderColor.cgColor }
    }
}
