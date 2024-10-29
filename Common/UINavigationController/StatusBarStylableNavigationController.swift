//
//  StatusBarStylableNavigationController.swift
//

import UIKit

// MARK: - StatusBarStylableNavigationController
public final class StatusBarStylableNavigationController: UINavigationController {
    public override var preferredStatusBarStyle: UIStatusBarStyle { topViewController?.preferredStatusBarStyle ?? .default }
}
