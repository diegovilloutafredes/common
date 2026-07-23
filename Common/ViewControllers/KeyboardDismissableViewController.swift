//
//  KeyboardDismissableViewController.swift
//

import UIKit

// MARK: - KeyboardDismissableViewController

/// A base view controller that automatically dismisses the keyboard when the view is tapped.
class KeyboardDismissableViewController: BaseViewController {}

extension KeyboardDismissableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAsKeyboardDismissable()
    }
}
