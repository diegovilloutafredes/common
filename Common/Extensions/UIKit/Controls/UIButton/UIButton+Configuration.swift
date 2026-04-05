//
//  UIButton+Configuration.swift
//

import UIKit

extension UIButton {
    
    /// Sets the button configuration and returns self (chainable).
    /// - Parameter configuration: The configuration to set.
    @discardableResult
    public func configuration(_ configuration: Configuration) -> Self {
        with { $0.configuration = configuration }
    }
}
