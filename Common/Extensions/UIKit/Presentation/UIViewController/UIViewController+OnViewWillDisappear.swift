//
//  UIViewController+OnViewWillDisappear.swift
//

import UIKit

private var onViewWillDisappearActionKey: UInt8 = 0

extension UIViewController {
    private var onViewWillDisappearAction: Handler<UIViewController>? {
        get { objc_getAssociatedObject(self, &onViewWillDisappearActionKey) as? Handler<UIViewController> }
        set { _ = Self._installViewWillDisappear; objc_setAssociatedObject(self, &onViewWillDisappearActionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
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
    private static let _installViewWillDisappear: Void = {
        let cls = UIViewController.self
        guard let method = class_getInstanceMethod(cls, #selector(viewWillDisappear(_:))) else {
            return print("Could not get `viewWillDisappear()` selector.")
        }
        guard let originalMethod = class_getInstanceMethod(cls, #selector(originalViewWillDisappear(_:))) else {
            return print("Could not get original `originalViewWillDisappear()` selector.")
        }
        guard let swizzledMethod = class_getInstanceMethod(cls, #selector(swizzledViewWillDisappear(_:))) else {
            return print("Could not get swizzled `swizzledViewWillDisappear()` selector.")
        }
        method_exchangeImplementations(method, originalMethod)
        method_exchangeImplementations(method, swizzledMethod)
    }()

    @objc private func originalViewWillDisappear(_ animated: Bool) {}

    @objc private func swizzledViewWillDisappear(_ animated: Bool) {
        originalViewWillDisappear(animated)
        if isViewLoaded { onViewWillDisappearAction?(self) }
    }
}
