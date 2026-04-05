//
//  UIViewController+OnViewDidDisappear.swift
//

import UIKit

extension UIViewController {
    private var onViewDidDisappearAction: Handler<UIViewController>? {
        get { associatedObject(for: "onViewDidDisappearAction") as? Handler<UIViewController> }
        set { swizzleViewDidDisappearIfNeeded(); set(associatedObject: newValue, for: "onViewDidDisappearAction") }
    }

// MARK: - onViewDidDisappear
    /// Sets a closure to be executed when `viewDidDisappear` is called and returns self (chainable).
    /// - Parameter onViewDidDisappear: The closure to execute.
    @discardableResult public func onViewDidDisappear(_ onViewDidDisappear: @escaping Handler<UIViewController>) -> Self {
        with { $0.onViewDidDisappearAction = onViewDidDisappear }
    }
}

// MARK: - onViewDidDisappear Swizzle
extension UIViewController {
    private static var notSwizzledViewDidDisappear = true
    @objc private func originalViewDidDisappear() {}
    
    @objc private func swizzledViewDidDisappear() {
        originalViewDidDisappear()
        if isViewLoaded { onViewDidDisappearAction?(self) }
    }

    private func swizzleViewDidDisappearIfNeeded() {
        guard Self.notSwizzledViewDidDisappear else { return }

        guard let viewControllerClass: AnyClass = object_getClass(self) else {
            return print("Could not get `UIViewController` class.")
        }

        let selector = #selector(viewDidDisappear(_:))
        guard let method = class_getInstanceMethod(viewControllerClass, selector) else {
            return print("Could not get `viewDidDisappear()` selector.")
        }

        let originalSelector = #selector(originalViewDidDisappear)
        guard let originalMethod = class_getInstanceMethod(viewControllerClass, originalSelector) else {
            return print("Could not get original `originalViewDidDisappear()` selector.")
        }

        let swizzledSelector = #selector(swizzledViewDidDisappear)
        guard let swizzledMethod = class_getInstanceMethod(viewControllerClass, swizzledSelector) else {
            return print("Could not get swizzled `swizzledViewDidDisappear()` selector.")
        }

        method_exchangeImplementations(method, originalMethod)
        method_exchangeImplementations(method, swizzledMethod)

        Self.notSwizzledViewDidDisappear = false
    }
}
