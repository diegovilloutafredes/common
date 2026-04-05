//
//  UIColor+Blend.swift
//

import UIKit

extension UIColor {
    
    /// Blends two colors with a specified weight.
    /// - Parameters:
    ///   - first: The first color.
    ///   - second: The second color.
    ///   - weight: The weight of the second color (0.0 to 1.0).
    /// - Returns: The blended color.
    public static func blend(
        _ first: UIColor,
        with second: UIColor,
        weight: CGFloat
    ) -> UIColor {
        let clampedWeight = max(0.0, min(1.0, weight))
        guard
            let c1 = first.rgbaComponents,
            let c2 = second.rgbaComponents
        else { return first }
        let red = c1.red + (c2.red - c1.red) * clampedWeight
        let green = c1.green + (c2.green - c1.green) * clampedWeight
        let blue = c1.blue + (c2.blue - c1.blue) * clampedWeight
        let alpha = c1.alpha + (c2.alpha - c1.alpha) * clampedWeight
        return .init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UIColor {
    
    /// Returns the midpoint color between two colors (50% blend).
    public static func blendedMidpoint(_ first: UIColor, _ second: UIColor) -> UIColor { blend(first, with: second, weight: 0.5) }
}
