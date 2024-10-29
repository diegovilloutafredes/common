//
//  UIView+Transform.swift
//

import UIKit

extension UIView {
    @discardableResult public func transform(_ transform: CGAffineTransform) -> Self {
        with { $0.transform = transform }
    }
}
