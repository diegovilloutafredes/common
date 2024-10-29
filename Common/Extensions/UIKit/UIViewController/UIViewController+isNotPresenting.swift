//
//  UIViewController+isNotPresenting.swift
//

import UIKit

// MARK: - isNotPresenting
extension UIViewController {
    public var isNotPresenting: Bool { presentedViewController.isNil }
}
