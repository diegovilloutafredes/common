//
//  UIViewController+IsUserInteractionEnabled.swift
//

import UIKit

extension UIViewController {
    
    /// Sets whether user interaction is enabled on the view and returns self (chainable).
    /// - Parameter isUserInteractionEnabled: `true` to enable user interaction.
    @discardableResult public func isUserInteractionEnabled(_ isUserInteractionEnabled: Bool) -> Self {
        with { $0.view.isUserInteractionEnabled(isUserInteractionEnabled) }
    }
}
