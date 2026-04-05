//
//  UIViewController+OnViewWillDisappear.swift
//

import UIKit

extension UIViewController {
    private var onViewWillDisappearAction: Handler<UIViewController>? {
        get { associatedObject(for: "onViewWillDisappearAction") as? Handler<UIViewController> }
        set { swizzleViewWillDisappearIfNeeded(); set(associatedObject: newValue, for: "onViewWillDisappearAction") }
    }
    
// MARK: - onViewWillDisappear
    /// Sets a closure to be executed when `viewWillDisappear` is called and returns self (chainable).
    /// - Parameter onViewWillDisappear: The closure to execute.
    @discardableResult public func onViewWillDisappear(_ onViewWillDisappear: @escaping Handler<UIViewController>) -> Self {
        with { $0.onViewWillDisappearAction = onViewWillDisappear }
    }
}

// MARK: - onViewWillDisappear Swizzle
extension UIViewController {
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
