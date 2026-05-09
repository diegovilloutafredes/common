//
//  UIEdgeInsets+DefaultValues.swift
//

import UIKit

// MARK: - Default Values
extension UIEdgeInsets {
    public enum DefaultValues {
        public enum StackView {

            /// Default margins for stack views.
            public static var margins: UIEdgeInsets {
                .init(
                    top: .DefaultValues.StackView.topMargin,
                    left: .DefaultValues.StackView.leftMargin,
                    bottom: .DefaultValues.StackView.bottomMargin,
                    right: .DefaultValues.StackView.rightMargin
                )
            }
        }
    }
}

// MARK: - Convenience Initializers
extension UIEdgeInsets {

    /// Equal inset on all four edges.
    public init(all inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: inset, right: inset)
    }

    /// Symmetric insets: `horizontal` applies to left/right, `vertical` to top/bottom.
    public init(horizontal: CGFloat = .zero, vertical: CGFloat = .zero) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
}
