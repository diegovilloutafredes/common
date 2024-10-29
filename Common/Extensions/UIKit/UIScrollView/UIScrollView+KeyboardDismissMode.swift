//
//  UIScrollView+KeyboardDismissMode.swift
//

import UIKit

extension UIScrollView {
    @discardableResult public func keyboardDismissMode(_ keyboardDismissMode: KeyboardDismissMode) -> Self {
        with { $0.keyboardDismissMode = keyboardDismissMode }
    }
}
