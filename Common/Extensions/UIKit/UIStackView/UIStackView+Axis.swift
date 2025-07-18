//
//  UIStackView+Axis.swift
//

import UIKit

extension UIStackView {
    @discardableResult public func axis(_ axis: NSLayoutConstraint.Axis) -> Self {
        with { $0.axis = axis }
    }
}
