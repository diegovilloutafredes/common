//
//  UIStackView+LayoutMargins.swift
//

import UIKit

extension UIStackView {
    @discardableResult public func layoutMargins(_ layoutMargins: UIEdgeInsets) -> Self {
        with { $0.layoutMargins = layoutMargins }
    }
}
