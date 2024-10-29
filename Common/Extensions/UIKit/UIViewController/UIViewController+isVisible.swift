//
//  UIViewController+isVisible.swift
//

import UIKit

extension UIViewController {
    public var isVisible: Bool { viewIfLoaded?.window != nil }
}
