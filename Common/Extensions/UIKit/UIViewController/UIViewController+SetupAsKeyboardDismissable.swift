//
//  UIViewController+SetupAsKeyboardDismissable.swift
//

import UIKit

extension UIViewController {
    public func setupAsKeyboardDismissable() {
        view.onTap { _ in self.dismissKeyboard() }
    }
}
