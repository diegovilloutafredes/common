//
//  UIColor+GetModifiedByPercentage.swift
//

import UIKit

extension UIColor {
    public func getModified(byPercentage percent: CGFloat) -> UIColor? {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }

        return .init(displayP3Red: min(red + percent / 100.0, 1.0), green: min(green + percent / 100.0, 1.0), blue: min(blue + percent / 100.0, 1.0), alpha: 1.0)
  }
}
