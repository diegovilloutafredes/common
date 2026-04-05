//
//  UIView+ShadowProperties.swift
//

import UIKit

extension UIView {
    
    /// Sets the shadow color and returns self (chainable).
    /// - Parameter shadowColor: The shadow color.
    @discardableResult public func shadowColor(_ shadowColor: UIColor?) -> Self {
        with { $0.layer.shadowColor = shadowColor?.cgColor }
    }
}

extension UIView {
    
    /// Sets the shadow offset and returns self (chainable).
    /// - Parameter shadowOffset: The shadow offset.
    @discardableResult public func shadowOffset(_ shadowOffset: CGSize) -> Self {
        with { $0.layer.shadowOffset = shadowOffset }
    }
}

extension UIView {
    
    /// Sets the shadow opacity and returns self (chainable).
    /// - Parameter shadowOpacity: The shadow opacity (0.0 to 1.0).
    @discardableResult public func shadowOpacity(_ shadowOpacity: Float) -> Self {
        with  { $0.layer.shadowOpacity = shadowOpacity }
    }
}

extension UIView {
    
    /// Sets the shadow radius and returns self (chainable).
    /// - Parameter shadowRadius: The shadow blur radius.
    @discardableResult public func shadowRadius(_ shadowRadius: CGFloat) -> Self {
        with { $0.layer.shadowRadius = shadowRadius }
    }
}

extension UIView {
    
    /// Configures all shadow properties and returns self (chainable).
    /// - Parameters:
    ///   - color: The shadow color.
    ///   - offset: The shadow offset. Defaults to `(0, -3)`.
    ///   - opacity: The shadow opacity. Defaults to `0`.
    ///   - radius: The shadow blur radius. Defaults to `3`.
    @discardableResult public func shadow(color: UIColor?, offset: CGSize = .init(width: .zero, height: -3), opacity: Float = .zero, radius: CGFloat = 3) -> Self {
        with {
            $0.shadowColor(color)
            $0.shadowOffset(offset)
            $0.shadowOpacity(opacity)
            $0.shadowRadius(radius)
        }
    }
}
