//
//  UIProgressView+.swift
//

import UIKit

extension UIProgressView {
    @discardableResult public func progress(_ progress: Float, animated: Bool = true) -> Self {
        with { $0.setProgress(progress, animated: animated) }
    }
}

extension UIProgressView {
    @discardableResult public func progressTintColor(_ progressTintColor: UIColor) -> Self {
        with { $0.progressTintColor = progressTintColor }
    }
}

extension UIProgressView {
    @discardableResult public func trackTintColor(_ trackTintColor: UIColor) -> Self {
        with { $0.trackTintColor = trackTintColor }
    }
}
