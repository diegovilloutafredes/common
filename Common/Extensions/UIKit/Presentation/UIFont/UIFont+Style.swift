//
//  UIFont+Style.swift
//

import UIKit

// MARK: - FontStyle
extension UIFont {
    /// Enumeration of common font styles.
    public enum FontStyle: String, Uppercaseable, CaseIterable {
        case black
        case bold
        case extraBold
        case extraLight
        case italic
        case light
        case medium
        case regular
        case semiBold
        case thin
    }
}
