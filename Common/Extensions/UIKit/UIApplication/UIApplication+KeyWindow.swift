//
//  UIApplication+KeyWindow.swift
//

import UIKit

// MARK: - KeyWindow
extension UIApplication {
    public var keyWindow: UIWindow? {
        connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first { $0.isKeyWindow }
        }
}
