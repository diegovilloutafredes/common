//
//  UIView+BorderWidth.swift
//

import UIKit

extension UIView {
    @discardableResult public func borderWidth(_ borderWidth: CGFloat) -> Self {
        with { $0.layer.borderWidth = borderWidth }
    }
}
