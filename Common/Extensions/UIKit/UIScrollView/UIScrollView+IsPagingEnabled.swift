//
//  UIScrollView+IsPagingEnabled.swift
//

import UIKit

extension UIScrollView {
    @discardableResult public func isPagingEnabled(_ isPagingEnabled: Bool) -> Self {
        with { $0.isPagingEnabled = isPagingEnabled }
    }
}
