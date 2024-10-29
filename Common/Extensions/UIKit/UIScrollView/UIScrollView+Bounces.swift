//
//  UIScrollView+Bounces.swift
//

import UIKit

extension UIScrollView {
    @discardableResult public func bounces(_ bounces: Bool) -> Self {
        with { $0.bounces = bounces }
    }
}
