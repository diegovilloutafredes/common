//
//  UIColor+Inverted.swift
//

import UIKit

extension UIColor {
    var inverted: UIColor {
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return .init(red: (1 - r), green: (1 - g), blue: (1 - b), alpha: a) // Assuming you want the same alpha value.
    }
}
