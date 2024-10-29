//
//  KeyboardDismissableViewController.swift
//

import UIKit

// MARK: - KeyboardDismissableViewController
class KeyboardDismissableViewController: BaseViewController {}

extension KeyboardDismissableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.onTap { _ in self.dismissKeyboard() }
    }
}
