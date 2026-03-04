//
//  CustomAlertWireframe.swift
//

import UIKit

// MARK: - CustomAlertWireframe
// MARK: - CustomAlertWireframe

/// A factory for creating `CustomAlertViewController` instances.
public enum CustomAlertWireframe {
    
    /// Creates and configures a new `CustomAlertViewController`.
    /// - Parameters:
    ///   - contentView: The view to display in the alert.
    ///   - handler: A closure to execute when dismissal is requested.
    /// - Returns: A configured `UIViewController` ready for presentation.
    public static func createModule(_ contentView: UIView, onDismissRequested handler: CompletionHandler = nil) -> UIViewController {
        CustomAlertViewController(contentView: contentView, onDismissRequested: handler)
            .modalPresentationStyle(.overFullScreen)
            .modalTransitionStyle(.crossDissolve)
    }
}
