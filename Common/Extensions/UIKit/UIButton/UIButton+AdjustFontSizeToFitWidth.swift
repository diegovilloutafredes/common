//
//  UIButton+AdjustFontSizeToFitWidth.swift
//

import UIKit

// MARK: - UIButton Extension
extension UIButton {
    @discardableResult public func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Bool) -> Self {
        with { $0.titleLabel?.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth }
    }
}
