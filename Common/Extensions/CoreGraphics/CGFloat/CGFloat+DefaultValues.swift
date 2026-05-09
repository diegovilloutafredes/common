//
//  CGFloat+DefaultValues.swift
//

import CoreGraphics

// MARK: - Default Values
extension CGFloat {

    /// Provides default constant values for various UI components layouts.
    public enum DefaultValues {
        public enum AlertView {
            public static let cornerRadius: CGFloat = 16
        }
        public enum BottomSheet {
            public static let cornerRadius: CGFloat = 8
        }
        public enum Button {
            public static let cornerRadius: CGFloat = 8
        }
        public enum Cell {
            public static let cornerRadius: CGFloat = 4
        }
        public enum StackView {
            public static let topMargin: CGFloat = 16
            public static let leftMargin: CGFloat = 16
            public static let bottomMargin: CGFloat = 16
            public static let rightMargin: CGFloat = 16
            public static let spacing: CGFloat = 16
        }
        public enum TextField {
            public static let cornerRadius: CGFloat = 8
        }
        public enum View {
            public static let cornerRadius: CGFloat = 16
        }
    }
}
