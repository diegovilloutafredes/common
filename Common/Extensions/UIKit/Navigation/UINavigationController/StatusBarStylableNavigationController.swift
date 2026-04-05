//
//  StatusBarStylableNavigationController.swift
//

import UIKit

// MARK: - StatusBarStylableNavigationController
/// A navigation controller that allows the status bar style to be determined by the top-most view controller.
public final class StatusBarStylableNavigationController: UINavigationController {
    
    /// The preferred status bar style, which delegates to the top-most view controller.
    public override var preferredStatusBarStyle: UIStatusBarStyle { topViewController?.preferredStatusBarStyle ?? .default }
}
