//
//  UIScrollView+ShowsHorizontalScrollIndicator.swift
//

import UIKit

extension UIScrollView {
    @discardableResult public func showsHorizontalScrollIndicator(_ showsHorizontalScrollIndicator: Bool) -> Self {
        with { $0.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator }
    }
}
