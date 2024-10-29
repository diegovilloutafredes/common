//
//  UITextField+Font.swift
//

import UIKit

extension UITextField {
    @discardableResult public func font(_ font: UIFont) -> Self {
        with { $0.font = font }
    }
}
