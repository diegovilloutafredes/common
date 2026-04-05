//
//  UIViewController+OnViewWillAppear.swift
//

import UIKit

extension UIViewController {
    private var onViewWillAppearAction: Handler<UIViewController>? {
        get { associatedObject(for: "onViewWillAppearAction") as? Handler<UIViewController> }
        set { swizzleViewWillAppearIfNeeded(); set(associatedObject: newValue, for: "onViewWillAppearAction") }
    }
    
// MARK: - onViewWillAppear
    /// Sets a closure to be executed when `viewWillAppear` is called and returns self (chainable).
    /// - Parameter onViewWillAppear: The closure to execute.
    @discardableResult public func onViewWillAppear(_ onViewWillAppear: @escaping Handler<UIViewController>) -> Self {
        with { $0.onViewWillAppearAction = onViewWillAppear }
    }
}

// MARK: - onViewWillAppear Swizzle
extension UIViewController {
    private static var notSwizzledViewWillAppear = true
    @objc private func originalViewWillAppear() {}

    @objc private func swizzledViewWillAppear() {
        originalViewWillAppear()
        if isViewLoaded { onViewWillAppearAction?(self) }
    }

    private func swizzleViewWillAppearIfNeeded() {
        guard Self.notSwizzledViewWillAppear else { return }

        guard let viewControllerClass: AnyClass = object_getClass(self) else {
            return print("Could not get `UIViewController` class.")
        }

        let selector = #selector(viewWillAppear(_:))
        guard let method = class_getInstanceMethod(viewControllerClass, selector) else {
            return print("Could not get `viewWillAppear()` selector.")
        }

        let originalSelector = #selector(originalViewWillAppear)
        guard let originalMethod = class_getInstanceMethod(viewControllerClass, originalSelector) else {
            return print("Could not get original `originalViewWillAppear()` selector.")
        }

        let swizzledSelector = #selector(swizzledViewWillAppear)
        guard let swizzledMethod = class_getInstanceMethod(viewControllerClass, swizzledSelector) else {
            return print("Could not get swizzled `swizzledViewWillAppear()` selector.")
        }

        method_exchangeImplementations(method, originalMethod)
        method_exchangeImplementations(method, swizzledMethod)

        Self.notSwizzledViewWillAppear = false
    }
}
