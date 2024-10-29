//
//  UIBarButtonItem+Action.swift
//

import UIKit

extension UIBarButtonItem {
    @discardableResult public func action(_ action: Selector?) -> Self {
        with { $0.action = action }
    }
}
