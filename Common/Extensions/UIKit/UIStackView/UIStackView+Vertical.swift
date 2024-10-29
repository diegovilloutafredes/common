//
//  UIStackView+Vertical.swift
//

import UIKit

extension UIStackView {
    @discardableResult public func vertical(alignment: Alignment = .fill, distribution: Distribution = .fill, margins: UIEdgeInsets = .zero, spacing: CGFloat = .zero) -> Self {
        with {
            $0.alignment = alignment
            $0.axis = .vertical
            $0.distribution = distribution
            $0.insetsLayoutMarginsFromSafeArea(false)
            $0.isLayoutMarginsRelativeArrangement(true)
            $0.layoutMargins = margins
            $0.spacing = spacing
        }
    }
}
