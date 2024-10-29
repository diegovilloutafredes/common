//
//  UIViewController+Subviews.swift
//

import UIKit

// MARK: - Subviews
extension UIViewController {
    @discardableResult public func subviews(_ subviews: [UIView]) -> Self {
        with { $0.view.subviews(subviews) }
    }

    @discardableResult public func subviews(@UIViewsBuilder _ subviews: () -> [UIView]) -> Self {
        with { $0.subviews(subviews()) }
    }
}
