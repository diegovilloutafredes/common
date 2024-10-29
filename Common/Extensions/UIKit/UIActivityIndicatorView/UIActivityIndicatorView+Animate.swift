//
//  UIActivityIndicatorView+Animate.swift
//

import UIKit

extension UIActivityIndicatorView {
    @discardableResult public func animate() -> Self {
        with { $0.startAnimating() }
    }
}
