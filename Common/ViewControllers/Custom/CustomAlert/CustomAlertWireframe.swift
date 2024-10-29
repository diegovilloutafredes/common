//
//  CustomAlertWireframe.swift
//

import UIKit

// MARK: - CustomAlertWireframe
public enum CustomAlertWireframe {
    public static func createModule(_ contentView: UIView, onDismissRequested handler: CompletionHandler = nil) -> UIViewController {
        CustomAlertViewController(contentView: contentView, onDismissRequested: handler)
            .modalPresentationStyle(.overFullScreen)
            .modalTransitionStyle(.crossDissolve)
    }
}
