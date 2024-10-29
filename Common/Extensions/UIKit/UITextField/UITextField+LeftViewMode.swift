//
//  UITextField+LeftViewMode.swift
//

import UIKit

extension UITextField {
    @discardableResult public func leftViewMode(_ leftViewMode: ViewMode) -> Self {
        with { $0.leftViewMode = leftViewMode }
    }
}
