//
//  UIView+RoundCorners.swift
//

import UIKit

// MARK: - UIView+RoundCorners
extension UIView {
    @discardableResult public func round(corners: CACornerMask = .all, radius: CGFloat = .DefaultValues.View.cornerRadius) -> Self {
        with {
            $0
                .cornerRadius(radius)
                .maskedCorners(corners)
        }
    }
}
