//
//  UIView+Alpha.swift
//

import UIKit

extension UIView {
    @discardableResult public func alpha(_ alpha: CGFloat) -> Self {
        with { $0.alpha = alpha }
    }
}
