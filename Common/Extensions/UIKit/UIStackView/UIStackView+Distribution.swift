//
//  UIStackView+Distribution.swift
//

import UIKit

extension UIStackView {
    
    /// Sets the distribution and returns self (chainable).
    /// - Parameter distribution: The distribution to set.
    @discardableResult public func distribution(_ distribution: Distribution) -> Self {
        with { $0.distribution = distribution }
    }
}
