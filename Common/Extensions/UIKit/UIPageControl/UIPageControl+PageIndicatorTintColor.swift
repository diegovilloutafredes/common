//
//  UIPageControl+PageIndicatorTintColor.swift
//

import UIKit

extension UIPageControl {
    @discardableResult public func pageIndicatorTintColor(_ pageIndicatorTintColor: UIColor) -> Self {
        with { $0.pageIndicatorTintColor = pageIndicatorTintColor }
    }
}
