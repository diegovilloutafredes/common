//
//  UIViewController+KeyboardDismissable.swift
//

import UIKit

// MARK: - KeyboardDismissable
extension UIViewController: KeyboardDismissable {
    @objc public func dismissKeyboard() { view.endEditing(true) }
}
