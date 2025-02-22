//
//  UISheetPresentationController+PrefersGrabberVisible.swift
//

import UIKit

extension UISheetPresentationController {
    @discardableResult public func prefersGrabberVisible(_ prefersGrabberVisible: Bool) -> Self { with { $0.prefersGrabberVisible = prefersGrabberVisible } }
}
