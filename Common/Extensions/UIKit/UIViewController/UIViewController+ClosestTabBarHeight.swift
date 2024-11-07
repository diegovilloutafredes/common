//
//  UIViewController+ClosestTabBarHeight.swift
//

import UIKit

// MARK: - ClosestTabBarHeight
extension UIViewController {
    public var closestTabBarHeight: CGFloat { tabBarController?.tabBarHeight ?? .zero }
}
