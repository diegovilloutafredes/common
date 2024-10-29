//
//  UIViewController+IsPresenting.swift
//

import UIKit

// MARK: - isPresenting
extension UIViewController {
    public var isPresenting: Bool { presentedViewController.isNotNil }
}
