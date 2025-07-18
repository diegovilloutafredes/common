//
//  UIButton+AdjustFontSizeToFitWidth.swift
//

import UIKit

// MARK: - UIButton Extension
extension UIButton {
    @discardableResult public func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Bool = true) -> Self {
        with { $0.titleLabel?.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth }
    }
}
