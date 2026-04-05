//
//  UIView+DebugMode.swift
//

import UIKit

extension UIView {
    
    /// Enables debug mode with random background colors and frame info and returns self (chainable).
    /// - Parameter applyToSubviews: `true` to apply to all subviews recursively.
    @discardableResult public func debugMode(applyToSubviews: Bool = false) -> Self {
        with {
            guard applyToSubviews else {
                $0.randomBackgroundColor()
                $0.addFrameInfo()
                return
            }
            $0.applyToAllSubviews {
                $0.randomBackgroundColor()
                $0.addFrameInfo()
            }
        }
    }
}
