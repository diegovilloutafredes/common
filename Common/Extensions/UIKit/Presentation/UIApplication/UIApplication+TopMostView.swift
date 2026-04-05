//
//  UIApplication+TopMostView.swift
//

import UIKit

// MARK: - Top Most View
// MARK: - Top Most View
extension UIApplication {
    
    /// Returns the view of the top-most view controller.
    public var topMostView: UIView? { topMostViewController?.view }
}
