//
//  UIButton+Font.swift
//

import UIKit

extension UIButton {
    @discardableResult public func font(_ font: UIFont) -> Self {
        with { $0.titleLabel?.font(font) }
    }
}
