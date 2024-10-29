//
//  UIView+ShadowProperties.swift
//

import UIKit

extension UIView {
    @discardableResult public func shadowColor(_ shadowColor: CGColor?) -> Self {
        with { $0.layer.shadowColor = shadowColor }
    }
}

extension UIView {
    @discardableResult public func shadowOffset(_ shadowOffset: CGSize) -> Self {
        with { $0.layer.shadowOffset = shadowOffset }
    }
}

extension UIView {
    @discardableResult public func shadowOpacity(_ shadowOpacity: Float) -> Self {
        with  { $0.layer.shadowOpacity = shadowOpacity }
    }
}

extension UIView {
    @discardableResult public func shadowRadius(_ shadowRadius: CGFloat) -> Self {
        with { $0.layer.shadowRadius = shadowRadius }
    }
}

extension UIView {
    @discardableResult public func shadow(color: CGColor?, offset: CGSize = .init(width: .zero, height: -3), opacity: Float = .zero, radius: CGFloat = 3) -> Self {
        with {
            $0.shadowColor(color)
            $0.shadowOffset(offset)
            $0.shadowOpacity(opacity)
            $0.shadowRadius(radius)
        }
    }
}
