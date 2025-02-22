//
//  UIPageControl+CurrentPageIndicatorTintColor.swift
//

import UIKit

extension UIPageControl {
    @discardableResult public func currentPageIndicatorTintColor(_ currentPageIndicatorTintColor: UIColor) -> Self {
        with { $0.currentPageIndicatorTintColor = currentPageIndicatorTintColor }
    }
}
