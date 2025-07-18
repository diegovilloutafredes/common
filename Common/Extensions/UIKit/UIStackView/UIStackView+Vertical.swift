//
//  UIStackView+Vertical.swift
//

import UIKit

extension UIStackView {
    @discardableResult public func vertical(alignment: Alignment = .fill, distribution: Distribution = .fill, margins: UIEdgeInsets = .zero, spacing: CGFloat = .zero) -> Self {
        self.alignment(alignment)
            .axis(.vertical)
            .distribution(distribution)
            .insetsLayoutMarginsFromSafeArea(false)
            .isLayoutMarginsRelativeArrangement(true)
            .layoutMargins(margins)
            .spacing(spacing)
    }
}
