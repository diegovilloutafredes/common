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
        let name = "\(name.uppercasingFirstLetter)-\(style.uppercasingFirstLetter)"
        guard let font = UIFont(name: name, size: size) else {
            Logger.log(["Couldn't find font": name])
            return switch style {
            case .black, .bold, .extraBold, .medium, .semiBold: .boldSystemFont(ofSize: size)
            case .extraLight, .light, .regular, .thin: .systemFont(ofSize: size)
            case .italic: .italicSystemFont(ofSize: size)
            }
        }
        return font
    }
}
