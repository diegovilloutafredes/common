//
//  UIScrollView+ShowsVerticalScrollIndicator.swift
//

import UIKit

extension UIScrollView {
    @discardableResult public func showsVerticalScrollIndicator(_ showsVerticalScrollIndicator: Bool) -> Self {
        with { $0.showsVerticalScrollIndicator = showsVerticalScrollIndicator }
    }
}
