//
//  UILabel+TextColor.swift
//

import UIKit

extension UILabel {
    @discardableResult public func textColor(_ textColor: UIColor? = .black) -> Self {
        with { $0.textColor = textColor }
    }
}
