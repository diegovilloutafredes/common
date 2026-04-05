//
//  UINavigationBar+TitleColor.swift
//

import UIKit

extension UINavigationBar {
    
    /// Returns the foreground color of the navigation bar title.
    public var titleColor: UIColor? { standardAppearance.titleTextAttributes[.foregroundColor] as? UIColor }
}
