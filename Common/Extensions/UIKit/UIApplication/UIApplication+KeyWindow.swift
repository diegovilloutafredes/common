//
//  UIApplication+KeyWindow.swift
//

import UIKit

// MARK: - KeyWindow
extension UIApplication {
    public var keyWindow: UIWindow? {
        connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first { $0 is UIWindowScene }
            .flatMap { $0 as? UIWindowScene }?
            .windows
            .first { $0.isKeyWindow }
        }
}
