//
//  UIImageView+TintColor.swift
//

import UIKit

extension UIImageView {
    @discardableResult public func tintColor(_ tintColor: UIColor?) -> Self {
        with { $0.tintColor = tintColor }
    }
}
