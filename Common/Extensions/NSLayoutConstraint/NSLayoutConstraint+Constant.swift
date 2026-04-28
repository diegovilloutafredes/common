//
//  NSLayoutConstraint+Constant.swift
//

import UIKit

extension NSLayoutConstraint {

    @discardableResult public func constant(_ constant: CGFloat) -> Self {
        with { $0.constant = constant }
    }

    @discardableResult public func priority(_ priority: UILayoutPriority) -> Self {
        with { $0.priority = priority }
    }
}
