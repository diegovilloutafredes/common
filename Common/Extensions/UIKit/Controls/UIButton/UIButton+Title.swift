//
//  UIButton+Title.swift
//

import UIKit

extension UIButton {
    
    /// Sets the title for a specific state and returns self (chainable).
    /// - Parameters:
    ///   - title: The title string.
    ///   - state: The control state. Defaults to `.normal`.
    @discardableResult public func title(_ title: String?, for state: State = .normal) -> Self {
        with { $0.setTitle(title, for: state) }
    }
}
