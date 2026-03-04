//
//  UIFont+AppFonts.swift
//

import Common
import UIKit

// MARK: - App Fonts
extension UIFont {

    // MARK: - FamilyName
    enum _FamilyName: String, Uppercaseable, CaseIterable {
        case montserrat
        case varelaRound
    }

    // MARK: - DefaultValues
    enum _DefaultValues {
        static var familyName: _FamilyName { .montserrat }
        static var style: FontStyle { .regular }
    }
}

extension UIFont {
    static func appFont(_ familyName: _FamilyName = _DefaultValues.familyName, style: FontStyle = _DefaultValues.style, size: CGFloat) -> UIFont {
        font(familyName, with: style, size: size)
    }
}

extension UIFont {
    static func registerAppFonts(_ names: [_FamilyName] = _FamilyName.allCases, styles: [FontStyle] = FontStyle.allCases, type: String = "ttf") {
        register(fonts: names, styles: styles, type: type)
    }
}
