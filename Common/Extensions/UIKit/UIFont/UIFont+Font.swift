//
//  UIFont+Font.swift
//

import UIKit

extension UIFont {
    public static func font(_ name: Uppercaseable, with style: FontStyle = .regular, size: CGFloat) -> UIFont {
        let name = "\(name.uppercasingFirstLetter)-\(style.uppercasingFirstLetter)"
        guard let font = UIFont(name: name, size: size) else {
            Logger.log(["Couldn't find font": name])
            switch style {
            case .regular: return .systemFont(ofSize: size)
            case .medium, .bold, .extraBold, .semiBold: return .boldSystemFont(ofSize: size)
            }
        }
        return font
    }
}
