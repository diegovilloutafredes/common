//
//  UIViewController+OnViewIsAppearing.swift
//

import UIKit

nonisolated(unsafe) private var onViewIsAppearingActionKey: UInt8 = 0

extension UIViewController {
    private var onViewIsAppearingAction: Handler<UIViewController>? {
        get { objc_getAssociatedObject(self, &onViewIsAppearingActionKey) as? Handler<UIViewController> }
        set { _ = Self._installViewIsAppearing; objc_setAssociatedObject(self, &onViewIsAppearingActionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

// MARK: - onViewIsAppearing
    /// Sets a closure to be executed when `viewIsAppearing` is called and returns self (chainable).
    /// - Parameter onViewIsAppearing: The closure to execute.
    @discardableResult public func onViewIsAppearing(_ onViewIsAppearing: @escaping Handler<UIViewController>) -> Self {
        with { $0.onViewIsAppearingAction = onViewIsAppearing }
    }
}

// MARK: - onViewIsAppearing Swizzle
extension UIViewController {
    private static let _installViewIsAppearing: Void = {
        let cls = UIViewController.self
        guard let method = class_getInstanceMethod(cls, #selector(viewIsAppearing(_:))) else {
            return print("Could not get `viewIsAppearing()` selector.")
        }
        guard let originalMethod = class_getInstanceMethod(cls, #selector(originalViewIsAppearing(_:))) else {
            return print("Could not get original `originalViewIsAppearing()` selector.")
        }
        guard let swizzledMethod = class_getInstanceMethod(cls, #selector(swizzledViewIsAppearing(_:))) else {
            return print("Could not get swizzled `swizzledViewIsAppearing()` selector.")
        }
        method_exchangeImplementations(method, originalMethod)
        method_exchangeImplementations(method, swizzledMethod)
    }()

    @objc private func originalViewIsAppearing(_ animated: Bool) {}

    @objc private func swizzledViewIsAppearing(_ animated: Bool) {
        originalViewIsAppearing(animated)
        if isViewLoaded { onViewIsAppearingAction?(self) }
    }
}
