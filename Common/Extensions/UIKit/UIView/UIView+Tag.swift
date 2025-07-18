//
//  UIView+Tag.swift
//

import UIKit

extension UIView {
    @discardableResult public func tag(_ tag: Int) -> Self {
        with { $0.tag = tag }
    }
}
