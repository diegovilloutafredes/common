//
//  UIApplication+KeyWindow.swift
//

import UIKit

// MARK: - KeyWindow
// MARK: - KeyWindow
extension UIApplication {
    
    /// Returns the current key window of the application.
    /// Searches through connected scenes to find the foreground active window scene.
    public var keyWindow: UIWindow? {
        connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first { $0.isKeyWindow }
        }
}
