//
//  UIApplication+TopMostView.swift
//

import UIKit

// MARK: - Top Most View
extension UIApplication {
    public var topMostView: UIView? { topMostViewController?.view }
}
