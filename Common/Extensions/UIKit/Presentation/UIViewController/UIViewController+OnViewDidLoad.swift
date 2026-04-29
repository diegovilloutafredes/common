//
//  UIViewController+OnViewDidLoad.swift
//

import UIKit

private var onViewDidLoadActionKey: UInt8 = 0

extension UIViewController {
    private var onViewDidLoadAction: Handler<UIViewController>? {
        get { objc_getAssociatedObject(self, &onViewDidLoadActionKey) as? Handler<UIViewController> }
        set { _ = Self._installViewDidLoad; objc_setAssociatedObject(self, &onViewDidLoadActionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
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
    private static let _installViewDidLoad: Void = {
        let cls = UIViewController.self
        guard let method = class_getInstanceMethod(cls, #selector(viewDidLoad)) else {
            return print("Could not get `viewDidLoad()` selector.")
        }
        guard let originalMethod = class_getInstanceMethod(cls, #selector(originalViewDidLoad)) else {
            return print("Could not get original `originalViewDidLoad()` selector.")
        }
        guard let swizzledMethod = class_getInstanceMethod(cls, #selector(swizzledViewDidLoad)) else {
            return print("Could not get swizzled `swizzledViewDidLoad()` selector.")
        }
        method_exchangeImplementations(method, originalMethod)
        method_exchangeImplementations(method, swizzledMethod)
    }()

    @objc private func originalViewDidLoad() {}

    @objc private func swizzledViewDidLoad() {
        originalViewDidLoad()
        if isViewLoaded { onViewDidLoadAction?(self) }
    }
}
