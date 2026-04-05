//
//  UIProgressView+.swift
//

import UIKit

extension UIProgressView {
    
    /// Sets the progress value and returns self (chainable).
    /// - Parameters:
    ///   - progress: The progress value (0.0 to 1.0).
    ///   - animated: Whether to animate the change. Defaults to `true`.
    @discardableResult public func progress(_ progress: Float, animated: Bool = true) -> Self {
        with { $0.setProgress(progress, animated: animated) }
    }
}

extension UIProgressView {
    
    /// Sets the progress tint color and returns self (chainable).
    /// - Parameter progressTintColor: The color for the filled portion.
    @discardableResult public func progressTintColor(_ progressTintColor: UIColor) -> Self {
        with { $0.progressTintColor = progressTintColor }
    }
}

extension UIProgressView {
    
    /// Sets the track tint color and returns self (chainable).
    /// - Parameter trackTintColor: The color for the unfilled portion.
    @discardableResult public func trackTintColor(_ trackTintColor: UIColor) -> Self {
        with { $0.trackTintColor = trackTintColor }
    }
}
