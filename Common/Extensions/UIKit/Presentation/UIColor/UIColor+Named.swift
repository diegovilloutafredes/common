//
//  UIColor+Named.swift
//

import UIKit

extension UIColor {
    
    /// Returns a color from the asset catalog by name.
    /// - Parameter named: The name of the color.
    /// - Returns: The color, or `nil` if not found.
    public static func named(_ named: String) -> UIColor? { .init(named: named) }
}
