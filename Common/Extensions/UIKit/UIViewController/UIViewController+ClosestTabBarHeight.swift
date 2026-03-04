//
//  UIViewController+ClosestTabBarHeight.swift
//

import UIKit

// MARK: - ClosestTabBarHeight
extension UIViewController {
    
    /// Returns the height of the closest tab bar, or zero if none.
    public var closestTabBarHeight: CGFloat { tabBarController?.tabBarHeight ?? .zero }
}
