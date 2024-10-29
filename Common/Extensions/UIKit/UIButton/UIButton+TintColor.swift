//
//  UIButton+TintColor.swift
//

import UIKit

extension UIButton {
    @discardableResult public func tintColor(_ tintColor: UIColor?) -> Self {
        with { $0.tintColor = tintColor }
    }
}
