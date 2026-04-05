//
//  UIViewController+DebugMode.swift
//

import UIKit

extension UIViewController {
    
    /// Enables debug mode on the view controller's view and returns self (chainable).
    @discardableResult public func debugMode() -> Self {
        with { $0.view.debugMode(applyToSubviews: true) }
    }
}
