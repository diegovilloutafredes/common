//
//  UIStackView+Horizontal.swift
//

import UIKit

extension UIStackView {
    
    /// Configures the stack view with horizontal layout and returns self (chainable).
    /// - Parameters:
    ///   - alignment: The alignment. Defaults to `.fill`.
    ///   - distribution: The distribution. Defaults to `.fill`.
    ///   - margins: The layout margins. Defaults to `.zero`.
    ///   - spacing: The spacing between items. Defaults to `0`.
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
