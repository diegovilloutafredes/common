//
//  UIView+RemoveSubviews.swift
//

import UIKit

extension UIView {
    public func removeSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}
