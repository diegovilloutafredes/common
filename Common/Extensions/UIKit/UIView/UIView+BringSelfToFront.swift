//
//  UIView+BringSelfToFront.swift
//

import UIKit

extension UIView {
    @discardableResult public func bringSelfToFront() -> Self {
        with { $0.superview?.bringToFront($0) }
    }
}
