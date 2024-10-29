//
//  UIView+CornerRadius.swift
//

import UIKit

extension UIView {
    @discardableResult public func cornerRadius(_ cornerRadius: CGFloat) -> Self {
        with { $0.layer.cornerRadius = cornerRadius }
    }
}
