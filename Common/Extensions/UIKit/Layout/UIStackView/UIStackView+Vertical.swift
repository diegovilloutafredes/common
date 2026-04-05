//
//  UIStackView+Vertical.swift
//

import UIKit

extension UIStackView {
    
    /// Configures the stack view with vertical layout and returns self (chainable).
    /// - Parameters:
    ///   - alignment: The alignment. Defaults to `.fill`.
    ///   - distribution: The distribution. Defaults to `.fill`.
    ///   - margins: The layout margins. Defaults to `.zero`.
    ///   - spacing: The spacing between items. Defaults to `0`.
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
