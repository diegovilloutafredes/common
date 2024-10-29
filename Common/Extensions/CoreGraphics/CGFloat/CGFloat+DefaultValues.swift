//
//  CGFloat+DefaultValues.swift
//

import CoreGraphics

// MARK: - Default Values
extension CGFloat {
    public enum DefaultValues {
        public enum AlertView {
            public static var cornerRadius: CGFloat { 16 }
        }
        public enum BottomSheet {
            public static var cornerRadius: CGFloat { 8 }
        }
        public enum Button {
            public static var cornerRadius: CGFloat { 8 }
        }
        public enum Cell {
            public static var cornerRadius: CGFloat { 4 }
        }
        public enum StackView {
            public static var topMargin: CGFloat { 16 }
            public static var leftMargin: CGFloat { 16 }
            public static var bottomMargin: CGFloat { 16 }
            public static var rightMargin: CGFloat { 16 }
            public static var spacing: CGFloat { 16 }
        }
        public enum TextField {
            public static var cornerRadius: CGFloat { 8 }
        }
        public enum View {
            public static var cornerRadius: CGFloat { 16 }
        }
    }
}
