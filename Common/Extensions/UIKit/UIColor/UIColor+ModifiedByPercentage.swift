//
//  UIColor+GetModifiedByPercentage.swift
//

import UIKit

extension UIColor {
    
    /// Returns a modified color by adjusting brightness by a percentage.
    /// - Parameter percent: The percentage to modify (positive to lighten, negative to darken).
    /// - Returns: The modified color, or `nil` if modification fails.
    public func getModified(byPercentage percent: CGFloat) -> UIColor? {
        var red: CGFloat = .zero
        var green: CGFloat = .zero
        var blue: CGFloat = .zero
        var alpha: CGFloat = .zero
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        return .init(displayP3Red: min(red + percent / 100.0, 1.0), green: min(green + percent / 100.0, 1.0), blue: min(blue + percent / 100.0, 1.0), alpha: 1.0)
    }
}
