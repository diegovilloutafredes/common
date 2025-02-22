//
//  UIPageControl+NumberOfPages.swift
//

import UIKit

extension UIPageControl {
    @discardableResult public func numberOfPages(_ numberOfPages: Int) -> Self {
        with { $0.numberOfPages = numberOfPages }
    }
}
