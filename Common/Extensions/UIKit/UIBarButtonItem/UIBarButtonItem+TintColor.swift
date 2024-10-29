//
//  UIBarButtonItem+TintColor.swift
//

import UIKit

extension UIBarButtonItem {
    @discardableResult public func tintColor(_ tintColor: UIColor?) -> Self {
        with { $0.tintColor = tintColor }
    }
}
