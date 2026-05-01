//
//  UIViewController+OnViewDidAppear.swift
//

import UIKit

nonisolated(unsafe) private var onViewDidAppearActionKey: UInt8 = 0

extension UIViewController {
    private var onViewDidAppearAction: Handler<UIViewController>? {
        get { objc_getAssociatedObject(self, &onViewDidAppearActionKey) as? Handler<UIViewController> }
        set { _ = Self._installViewDidAppear; objc_setAssociatedObject(self, &onViewDidAppearActionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

// MARK: - onViewDidAppear
    /// Sets a closure to be executed when `viewDidAppear` is called and returns self (chainable).
    /// - Parameter onViewDidAppear: The closure to execute.
    @discardableResult public func onViewDidAppear(_ onViewDidAppear: @escaping Handler<UIViewController>) -> Self {
        with { $0.onViewDidAppearAction = onViewDidAppear }
    }
}

// MARK: - onViewDidAppear Swizzle
extension UIViewController {
    private static let _installViewDidAppear: Void = {
        let cls = UIViewController.self
        guard let method = class_getInstanceMethod(cls, #selector(viewDidAppear(_:))) else {
            return print("Could not get `viewDidAppear()` selector.")
        }
        guard let originalMethod = class_getInstanceMethod(cls, #selector(originalViewDidAppear(_:))) else {
            return print("Could not get original `originalViewDidAppear()` selector.")
        }
        guard let swizzledMethod = class_getInstanceMethod(cls, #selector(swizzledViewDidAppear(_:))) else {
            return print("Could not get swizzled `swizzledViewDidAppear()` selector.")
        }
        method_exchangeImplementations(method, originalMethod)
        method_exchangeImplementations(method, swizzledMethod)
    }()

    @objc private func originalViewDidAppear(_ animated: Bool) {}

    @objc private func swizzledViewDidAppear(_ animated: Bool) {
        originalViewDidAppear(animated)
        if isViewLoaded { onViewDidAppearAction?(self) }
    }
}
