//
//  UIScrollView+IsScrollEnabled.swift
//

import UIKit

extension UIScrollView {
    @discardableResult public func isScrollEnabled(_ isScrollEnabled: Bool) -> Self {
        with { $0.isScrollEnabled = isScrollEnabled }
    }
}
