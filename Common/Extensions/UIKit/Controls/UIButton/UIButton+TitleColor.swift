//
//  UIButton+TitleColor.swift
//

import UIKit

extension UIButton {
    
    /// Sets the title color for a specific state and returns self (chainable).
    /// - Parameters:
    ///   - titleColor: The color to set.
    ///   - state: The control state. Defaults to `.normal`.
    @discardableResult public func titleColor(_ titleColor: UIColor?, for state: State = .normal) -> Self {
        with { $0.setTitleColor(titleColor, for: state) }
    }
}
