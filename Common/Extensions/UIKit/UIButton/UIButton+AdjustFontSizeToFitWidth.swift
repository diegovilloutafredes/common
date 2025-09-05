//
//  UIButton+AdjustFontSizeToFitWidth.swift
//

import UIKit

extension UIButton {
    @discardableResult public func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Bool = true) -> Self {
        with { $0.titleLabel?.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth }
    }
}
