//
//  UIView+Identity.swift
//

import UIKit

extension UIView {
    @discardableResult public func identity() -> Self {
        with { $0.transform(.identity) }
    }
}
