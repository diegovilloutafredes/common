//
//  UIBarButtonItem+Target.swift
//

import UIKit

extension UIBarButtonItem {
    @discardableResult public func target(_ target: AnyObject?) -> Self {
        with { $0.target = target }
    }
}
