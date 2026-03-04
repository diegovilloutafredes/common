//
//  UIWindow+InitWithScreenFrame.swift
//

import UIKit

extension UIWindow {
    
    /// Creates a window with the main screen's bounds.
    /// - Returns: A new window sized to the main screen.
    public static func initWithScreenFrame() -> Self { .init(frame: UIScreen.main.bounds) }
}
