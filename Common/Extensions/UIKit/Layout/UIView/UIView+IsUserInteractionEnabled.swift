//
//  UIView+IsUserInteractionEnabled.swift
//

import UIKit

extension UIView {
    
    /// Sets whether user interaction is enabled and returns self (chainable).
    /// - Parameter isUserInteractionEnabled: `true` to enable user interaction.
    @discardableResult public func isUserInteractionEnabled(_ isUserInteractionEnabled: Bool) -> Self {
        with { $0.isUserInteractionEnabled = isUserInteractionEnabled }
    }
}
