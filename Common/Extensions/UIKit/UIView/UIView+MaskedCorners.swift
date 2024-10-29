//
//  UIView+MaskedCorners.swift
//

import UIKit

extension UIView {
    @discardableResult public func maskedCorners(_ maskedCorners: CACornerMask) -> Self {
        with { $0.layer.maskedCorners = maskedCorners }
    }
}
