//
//  UIViewController+OnViewDidAppear.swift
//

import UIKit

// MARK: - onViewDidAppear Swizzle
extension UIViewController {
    private var onViewDidAppearAction: ViewControllerHandler? {
        get { associatedObject(for: "onViewDidAppearAction") as? ViewControllerHandler }
        set { swizzleViewDidAppearIfNeeded(); set(associatedObject: newValue, for: "onViewDidAppearAction") }
    }

    @discardableResult public func onViewDidAppear(_ onViewDidAppear: @escaping ViewControllerHandler) -> Self {
        with { $0.onViewDidAppearAction = onViewDidAppear }
    }

    private static var notSwizzledViewDidAppear = true
    @objc private func originalViewDidAppear() {}

    @objc private func swizzledViewDidAppear() {
        originalViewDidAppear()
        if isViewLoaded { onViewDidAppearAction?(self) }
    }

    private func swizzleViewDidAppearIfNeeded() {
        guard Self.notSwizzledViewDidAppear else { return }

        guard let viewControllerClass: AnyClass = object_getClass(self) else {
            return print("Could not get `UIViewController` class.")
        }

        let selector = #selector(viewDidAppear(_:))
        guard let method = class_getInstanceMethod(viewControllerClass, selector) else {
            return print("Could not get `viewDidAppear()` selector.")
        }

        let originalSelector = #selector(originalViewDidAppear)
        guard let originalMethod = class_getInstanceMethod(viewControllerClass, originalSelector) else {
            return print("Could not get original `originalViewDidAppear()` selector.")
        }

        let swizzledSelector = #selector(swizzledViewDidAppear)
        guard let swizzledMethod = class_getInstanceMethod(viewControllerClass, swizzledSelector) else {
            return print("Could not get swizzled `swizzledViewDidAppear()` selector.")
        }

        method_exchangeImplementations(method, originalMethod)
        method_exchangeImplementations(method, swizzledMethod)

        Self.notSwizzledViewDidAppear = false
    }
}
