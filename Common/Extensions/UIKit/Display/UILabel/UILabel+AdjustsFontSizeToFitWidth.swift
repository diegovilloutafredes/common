//
//  UILabel+AdjustsFontSizeToFitWidth.swift
//

import UIKit

extension UILabel {
    
    /// Sets whether the font size should adjust to fit the width and returns self (chainable).
    /// - Parameter adjustsFontSizeToFitWidth: `true` to enable adjustment. Defaults to `true`.
    @discardableResult public func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Bool = true) -> Self {
        with { $0.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth }
    }
}
