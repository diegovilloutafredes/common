//
//  UIScrollView+Delegate.swift
//

import UIKit

extension UIScrollView {
    @discardableResult public func delegate(_ delegate: UIScrollViewDelegate) -> Self {
        with { $0.delegate = delegate }
    }
}
