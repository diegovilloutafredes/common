//
//  UIView+Subviews.swift
//

import UIKit

// MARK: - Subviews
extension UIView {
    @discardableResult public func subviews(_ subviews: [UIView]) -> Self {
        with { view in
            switch self {
            case is UIStackView:
                (view as! UIStackView).views(subviews)
            case is UIVisualEffectView:
                subviews.forEach { (view as! UIVisualEffectView).contentView.addSubview($0) }
            default:
                subviews.forEach { view.addSubview($0) }
            }
        }
    }

    @discardableResult public func subviews(@UIViewsBuilder _ subviews: () -> [UIView] = {[]}) -> Self {
        with { $0.subviews(subviews()) }
    }
}
