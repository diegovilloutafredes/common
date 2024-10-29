//
//  UIView+BorderColor.swift
//

import UIKit

extension UIView {
    @discardableResult public func borderColor(_ borderColor: UIColor) -> Self {
        with { $0.layer.borderColor = borderColor.cgColor }
    }
}
