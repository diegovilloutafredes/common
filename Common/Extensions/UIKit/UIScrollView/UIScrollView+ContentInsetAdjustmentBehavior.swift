//
//  UIScrollView+ContentInsetAdjustmentBehavior.swift
//

import UIKit

extension UIScrollView {
    @discardableResult public func contentInsetAdjustmentBehavior(_ contentInsetAdjustmentBehavior: ContentInsetAdjustmentBehavior) -> Self {
        with { $0.contentInsetAdjustmentBehavior = contentInsetAdjustmentBehavior }
    }
}
