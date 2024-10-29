//
//  UIEdgeInsets+DefaultValues.swift
//

import UIKit

// MARK: - Default Values
extension UIEdgeInsets {
    public enum DefaultValues {
        public enum StackView {
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
