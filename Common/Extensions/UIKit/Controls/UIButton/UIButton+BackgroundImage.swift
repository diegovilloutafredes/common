//
//  UIButton+BackgroundImage.swift
//

import UIKit

extension UIButton {
    
    /// Sets the background image for a specific state and returns self (chainable).
    /// - Parameters:
    ///   - backgroundImage: The image to use as background.
    ///   - state: The control state. Defaults to `.normal`.
    @discardableResult public func backgroundImage(_ backgroundImage: UIImage?, for state: UIControl.State = .normal) -> Self {
        with { $0.setBackgroundImage(backgroundImage, for: state) }
    }
}
