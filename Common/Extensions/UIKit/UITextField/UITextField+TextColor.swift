//
//  UITextField+TextColor.swift
//

import UIKit

extension UITextField {
    @discardableResult public func textColor(_ textColor: UIColor? = .black) -> Self {
        with { $0.textColor = textColor }
    }
}
