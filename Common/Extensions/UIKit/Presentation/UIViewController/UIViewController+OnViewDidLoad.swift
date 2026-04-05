//
//  UIViewController+OnViewDidLoad.swift
//

import UIKit

extension UIViewController {
    private var onViewDidLoadAction: Handler<UIViewController>? {
        get { associatedObject(for: "onViewDidLoadAction") as? Handler<UIViewController> }
        set { swizzleViewDidLoadIfNeeded(); set(associatedObject: newValue, for: "onViewDidLoadAction") }
    }
    
// MARK: - onViewDidLoad
    /// Sets a closure to be executed when `viewDidLoad` is called and returns self (chainable).
    /// - Parameter onViewDidLoad: The closure to execute.
    @discardableResult public func onViewDidLoad(_ onViewDidLoad: @escaping Handler<UIViewController>) -> Self {
        with { $0.onViewDidLoadAction = onViewDidLoad }
    }
}

// MARK: - onViewDidLoad Swizzle
extension UIViewController {
    private static var notSwizzledViewDidLoad = true
    @objc private func originalViewDidLoad() {}

    @objc private func swizzledViewDidLoad() {
        originalViewDidLoad()
        if isViewLoaded { onViewDidLoadAction?(self) }
    }

    private func swizzleViewDidLoadIfNeeded() {
        guard Self.notSwizzledViewDidLoad else { return }
        
        guard let viewControllerClass: AnyClass = object_getClass(self) else {
            return print("Could not get `UIViewController` class.")
        }
        
        let selector = #selector(viewDidLoad)
        guard let method = class_getInstanceMethod(viewControllerClass, selector) else {
            return print("Could not get `viewDidLoad()` selector.")
        }
        
        let originalSelector = #selector(originalViewDidLoad)
        guard let originalMethod = class_getInstanceMethod(viewControllerClass, originalSelector) else {
            return print("Could not get original `originalViewDidLoad()` selector.")
        }
        
        let swizzledSelector = #selector(swizzledViewDidLoad)
        guard let swizzledMethod = class_getInstanceMethod(viewControllerClass, swizzledSelector) else {
            return print("Could not get swizzled `swizzledViewDidLoad()` selector.")
        }
        
        method_exchangeImplementations(method, originalMethod)
        method_exchangeImplementations(method, swizzledMethod)
        
        Self.notSwizzledViewDidLoad = false
    }
}
