//
//  UIButton+AdjustFontSizeToFitWidth.swift
//

import UIKit

extension UIButton {
    
    /// Sets whether the title label's font size should be adjusted to fit the width.
    /// - Parameter adjustsFontSizeToFitWidth: `true` to allow adjustment, `false` otherwise. Defaults to `true`.
    @discardableResult public func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Bool = true) -> Self {
        with { $0.titleLabel?.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth }
    }
}
