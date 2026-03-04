//
//  KeyboardDismissableViewController.swift
//

import UIKit

// MARK: - KeyboardDismissableViewController
// MARK: - KeyboardDismissableViewController

/// A base view controller that automatically dismisses the keyboard when the view is tapped.
class KeyboardDismissableViewController: BaseViewController {}

extension KeyboardDismissableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.onTap { _ in self.dismissKeyboard() }
    }
}
