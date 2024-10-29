//
//  UIWindow+InitWithScreenFrame.swift
//

import UIKit

extension UIWindow {
    public static func initWithScreenFrame() -> Self { .init(frame: UIScreen.main.bounds) }
}
