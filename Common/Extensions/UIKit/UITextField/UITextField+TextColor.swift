//
//  UITextField+TextColor.swift
//

import UIKit

extension UITextField {
    @discardableResult public func textColor(_ textColor: UIColor) -> Self {
        with { $0.textColor = textColor }
    }
}
