//
//  UIViewController+SetupAsKeyboardDismissable.swift
//

import UIKit

extension UIViewController {
    
    /// Configures the view to dismiss the keyboard on tap.
    public func setupAsKeyboardDismissable() {
        view.onTap { _ in self.dismissKeyboard() }
    }
}
