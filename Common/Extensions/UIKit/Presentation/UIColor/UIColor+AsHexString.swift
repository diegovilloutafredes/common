//
//  UIColor+AsHexString.swift
//

import UIKit

extension UIColor {
    
    /// Returns the hex string representation of the color (e.g., "#FF0000").
    public var asHexString: String {
        var red: CGFloat = .zero
        var green: CGFloat = .zero
        var blue: CGFloat = .zero
        var alpha: CGFloat = .zero
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        return .init(format: "#%02X%02X%02X", r, g, b)
    }
}
