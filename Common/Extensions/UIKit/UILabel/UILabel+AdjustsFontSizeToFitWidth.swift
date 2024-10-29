//
//  UILabel+AdjustsFontSizeToFitWidth.swift
//

import UIKit

extension UILabel {
    @discardableResult public func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Bool = true) -> Self {
        with { $0.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth }
    }
}
