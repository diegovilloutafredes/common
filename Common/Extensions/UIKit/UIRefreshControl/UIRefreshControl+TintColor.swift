//
//  UIRefreshControl+TintColor.swift
//

import UIKit

extension UIRefreshControl {
    @discardableResult public func tintColor(_ tintColor: UIColor) -> Self {
        with { $0.tintColor = tintColor }
    }
}
