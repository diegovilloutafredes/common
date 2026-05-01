//
//  UIViewController+OnViewDidDisappear.swift
//

import UIKit

nonisolated(unsafe) private var onViewDidDisappearActionKey: UInt8 = 0

extension UIViewController {
    private var onViewDidDisappearAction: Handler<UIViewController>? {
        get { objc_getAssociatedObject(self, &onViewDidDisappearActionKey) as? Handler<UIViewController> }
        set { _ = Self._installViewDidDisappear; objc_setAssociatedObject(self, &onViewDidDisappearActionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
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
    private static let _installViewDidDisappear: Void = {
        let cls = UIViewController.self
        guard let method = class_getInstanceMethod(cls, #selector(viewDidDisappear(_:))) else {
            return print("Could not get `viewDidDisappear()` selector.")
        }
        guard let originalMethod = class_getInstanceMethod(cls, #selector(originalViewDidDisappear(_:))) else {
            return print("Could not get original `originalViewDidDisappear()` selector.")
        }
        guard let swizzledMethod = class_getInstanceMethod(cls, #selector(swizzledViewDidDisappear(_:))) else {
            return print("Could not get swizzled `swizzledViewDidDisappear()` selector.")
        }
        method_exchangeImplementations(method, originalMethod)
        method_exchangeImplementations(method, swizzledMethod)
    }()

    @objc private func originalViewDidDisappear(_ animated: Bool) {}

    @objc private func swizzledViewDidDisappear(_ animated: Bool) {
        originalViewDidDisappear(animated)
        if isViewLoaded { onViewDidDisappearAction?(self) }
    }
}
