//
//  UIView+BringToFront.swift
//

import UIKit

extension UIView {
    @discardableResult public func bringToFront(_ subview: UIView) -> Self {
        with { $0.bringSubviewToFront(subview) }
    }
}
