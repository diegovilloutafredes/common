//
//  UIStackView+Horizontal.swift
//

import UIKit

extension UIStackView {
    @discardableResult public func horizontal(alignment: Alignment = .fill, distribution: Distribution = .fill, margins: UIEdgeInsets = .zero, spacing: CGFloat = .zero) -> Self {
        self.alignment(alignment)
            .axis(.horizontal)
            .distribution(distribution)
            .insetsLayoutMarginsFromSafeArea(false)
            .isLayoutMarginsRelativeArrangement(true)
            .layoutMargins(margins)
            .spacing(spacing)
    }
}
