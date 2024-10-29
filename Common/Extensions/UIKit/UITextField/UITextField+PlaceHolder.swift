//
//  UITextField+Placeholder.swift
//

import UIKit

extension UITextField {
    @discardableResult public func placeholder(_ text: String, color: UIColor, font: UIFont) -> Self {
        with {
            $0.attributedPlaceholder = .init(
                string: text,
                attributes: [
                    .font: font,
                    .foregroundColor: color
                ]
            )
        }
    }
}
