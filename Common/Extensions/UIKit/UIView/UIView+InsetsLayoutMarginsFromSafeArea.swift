//
//  UIView+InsetsLayoutMarginsFromSafeArea.swift
//

import UIKit

extension UIView {
    
    /// Sets whether layout margins are inset from safe area and returns self (chainable).
    /// - Parameter insetsLayoutMarginsFromSafeArea: `true` to inset from safe area.
    @discardableResult public func insetsLayoutMarginsFromSafeArea(_ insetsLayoutMarginsFromSafeArea: Bool) -> Self {
        with { $0.insetsLayoutMarginsFromSafeArea = insetsLayoutMarginsFromSafeArea }
    }
}
