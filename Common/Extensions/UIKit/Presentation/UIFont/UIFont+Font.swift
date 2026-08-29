//
//  UIFont+Font.swift
//

import UIKit

extension UIFont {

    /// Returns a custom font with the specified name, style, and size.
    /// Falls back to system font if the custom font cannot be loaded.
    /// - Parameters:
    ///   - name: The font name (must conform to `Uppercaseable`).
    ///   - style: The font style (e.g., .regular, .bold). Defaults to `.regular`.
    ///   - size: The font size.
    /// - Returns: The requested font or a system fallback.
    public static func font(_ name: Uppercaseable, with style: FontStyle = .regular, size: CGFloat) -> UIFont {
        let postScriptName = "\(name.uppercasingFirstLetter)-\(style.uppercasingFirstLetter)"
        guard let font = UIFont(name: postScriptName, size: size) else {
            Logger.log(["Couldn't find font": postScriptName])
            return systemFallback(for: style, size: size)
        }
        return font
    }

    /// The system font at the weight matching `style` (`.italic` → italic system font).
    static func systemFallback(for style: FontStyle, size: CGFloat) -> UIFont {
        switch style {
        case .italic: .italicSystemFont(ofSize: size)
        default:      .systemFont(ofSize: size, weight: style.systemWeight)
        }
    }
}

private extension UIFont.FontStyle {
    var systemWeight: UIFont.Weight {
        switch self {
        case .thin:       .thin
        case .extraLight: .ultraLight
        case .light:      .light
        case .regular:    .regular
        case .medium:     .medium
        case .semiBold:   .semibold
        case .bold:       .bold
        case .extraBold:  .heavy
        case .black:      .black
        case .italic:     .regular
        }
    }
}
