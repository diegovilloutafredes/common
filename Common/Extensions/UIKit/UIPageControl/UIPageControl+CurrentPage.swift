//
//  UIPageControl+CurrentPage.swift
//

import UIKit

extension UIPageControl {
    @discardableResult public func currentPage(_ currentPage: Int) -> Self {
        with { $0.currentPage = currentPage }
    }
}
