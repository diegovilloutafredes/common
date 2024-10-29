//
//  UIStackView+Views.swift
//

import UIKit

extension UIStackView {
    @discardableResult public func views(_ views: [UIView]) -> Self {
        with { sv in views.forEach { sv.addArrangedSubview($0) } }
    }

    @discardableResult public func views(@UIViewsBuilder _ views: () -> [UIView]) -> Self {
        with { $0.views(views()) }
    }
}
