//
//  UIView+.swift
//

import UIKit

extension UIView {
    @discardableResult public func randomBackgroundColor() -> Self {
        with { $0.backgroundColor(.randomColor) }
    }
}
