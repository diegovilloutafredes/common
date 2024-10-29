//
//  UIViewController+ClosestTabBarHeight.swift
//

import UIKit

// MARK: - ClosestTabBarHeight
extension UIViewController {
    var closestTabBarHeight: CGFloat { tabBarController?.tabBarHeight ?? .zero }
}
