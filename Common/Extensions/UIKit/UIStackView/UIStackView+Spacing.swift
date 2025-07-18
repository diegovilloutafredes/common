//
//  UIStackView+Spacing.swift
//

import UIKit

extension UIStackView {
    @discardableResult public func spacing(_ spacing: CGFloat) -> Self {
        with { $0.spacing = spacing }
    }
}
