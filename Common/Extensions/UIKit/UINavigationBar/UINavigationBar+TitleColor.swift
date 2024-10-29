//
//  UINavigationBar+TitleColor.swift
//

import UIKit

extension UINavigationBar {
    public var titleColor: UIColor? { standardAppearance.titleTextAttributes[.foregroundColor] as? UIColor }
}
