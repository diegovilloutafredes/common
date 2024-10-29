//
//  UITextField+RightViewMode.swift
//

import UIKit

extension UITextField {
    @discardableResult public func rightViewMode(_ rightViewMode: ViewMode) -> Self {
        with { $0.rightViewMode = rightViewMode }
    }
}
