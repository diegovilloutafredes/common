//
//  NSLayoutConstraint+Constant.swift
//

import UIKit

extension NSLayoutConstraint {
    @discardableResult public func constant(_ constant: Double) -> Self {
        with { $0.constant = constant }
    }
}
