//
//  UIViewController+KeyboardDismissable.swift
//

import UIKit

// MARK: - KeyboardDismissable

/// Makes UIViewController conform to KeyboardDismissable.
extension UIViewController: KeyboardDismissable {
    
    /// Dismisses the keyboard by ending editing on the view.
    @objc public func dismissKeyboard() { view.endEditing(true) }
}
