//
//  UIViewController+OnViewWillDisappear.swift
//

import UIKit

// MARK: - onViewWillDisappear Swizzle
extension UIViewController {
    private var onViewWillDisappearAction: ViewControllerHandler? {
        get { associatedObject(for: "onViewWillDisappearAction") as? ViewControllerHandler }
        set { swizzleViewWillDisappearIfNeeded(); set(associatedObject: newValue, for: "onViewWillDisappearAction") }
    }

    @discardableResult public func onViewWillDisappear(_ onViewWillDisappear: @escaping ViewControllerHandler) -> Self {
        with { $0.onViewWillDisappearAction = onViewWillDisappear }
    }

    private static var notSwizzledViewWillDisappear = true
    @objc private func originalViewWillDisappear() {}
    
    @objc private func swizzledViewWillDisappear() {
        originalViewWillDisappear()
        if isViewLoaded { onViewWillDisappearAction?(self) }
    }

    private func swizzleViewWillDisappearIfNeeded() {
        guard Self.notSwizzledViewWillDisappear else { return }

        guard let viewControllerClass: AnyClass = object_getClass(self) else {
            return print("Could not get `UIViewController` class.")
        }

        let selector = #selector(viewWillDisappear(_:))
        guard let method = class_getInstanceMethod(viewControllerClass, selector) else {
            return print("Could not get `viewWillDisappear()` selector.")
        }

        let originalSelector = #selector(originalViewWillDisappear)
        guard let originalMethod = class_getInstanceMethod(viewControllerClass, originalSelector) else {
            return print("Could not get original `originalViewWillDisappear()` selector.")
        }

        let swizzledSelector = #selector(swizzledViewWillDisappear)
        guard let swizzledMethod = class_getInstanceMethod(viewControllerClass, swizzledSelector) else {
            return print("Could not get swizzled `swizzledViewWillDisappear()` selector.")
        }

        method_exchangeImplementations(method, originalMethod)
        method_exchangeImplementations(method, swizzledMethod)

        Self.notSwizzledViewWillDisappear = false
    }
}
