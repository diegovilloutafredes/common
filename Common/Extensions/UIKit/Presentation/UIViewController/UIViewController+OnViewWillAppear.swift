//
//  UIViewController+OnViewWillAppear.swift
//

import UIKit

nonisolated(unsafe) private var onViewWillAppearActionKey: UInt8 = 0

extension UIViewController {
    private var onViewWillAppearAction: Handler<UIViewController>? {
        get { objc_getAssociatedObject(self, &onViewWillAppearActionKey) as? Handler<UIViewController> }
        set { _ = Self._installViewWillAppear; objc_setAssociatedObject(self, &onViewWillAppearActionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
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
    private static let _installViewWillAppear: Void = {
        let cls = UIViewController.self
        guard let method = class_getInstanceMethod(cls, #selector(viewWillAppear(_:))) else {
            return print("Could not get `viewWillAppear()` selector.")
        }
        guard let originalMethod = class_getInstanceMethod(cls, #selector(originalViewWillAppear(_:))) else {
            return print("Could not get original `originalViewWillAppear()` selector.")
        }
        guard let swizzledMethod = class_getInstanceMethod(cls, #selector(swizzledViewWillAppear(_:))) else {
            return print("Could not get swizzled `swizzledViewWillAppear()` selector.")
        }
        method_exchangeImplementations(method, originalMethod)
        method_exchangeImplementations(method, swizzledMethod)
    }()

    @objc private func originalViewWillAppear(_ animated: Bool) {}

    @objc private func swizzledViewWillAppear(_ animated: Bool) {
        originalViewWillAppear(animated)
        if isViewLoaded { onViewWillAppearAction?(self) }
    }
}
