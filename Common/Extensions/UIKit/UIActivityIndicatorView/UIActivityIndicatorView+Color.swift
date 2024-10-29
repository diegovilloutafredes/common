//
//  UIActivityIndicatorView+Color.swift
//

import UIKit

extension UIActivityIndicatorView {
    @discardableResult public func color(_ color: UIColor) -> Self {
        with { $0.color = color }
    }
}
