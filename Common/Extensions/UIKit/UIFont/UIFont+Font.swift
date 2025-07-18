//
//  UIFont+Font.swift
//

import UIKit

extension UIFont {
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
