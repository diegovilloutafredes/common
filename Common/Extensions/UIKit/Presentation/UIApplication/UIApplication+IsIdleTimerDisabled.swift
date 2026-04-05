//
//  UIApplication+IsIdleTimerDisabled.swift
//

import UIKit

// MARK: - isIdleTimerDisabled
// MARK: - isIdleTimerDisabled
extension UIApplication {
    
    /// Sets whether the idle timer is disabled and returns self.
    /// - Parameter isIdleTimerDisabled: `true` to disable the idle timer, `false` to enable it.
    @discardableResult
    public func isIdleTimerDisabled(_ isIdleTimerDisabled: Bool) -> Self {
        with { $0.isIdleTimerDisabled = isIdleTimerDisabled }
    }
}
