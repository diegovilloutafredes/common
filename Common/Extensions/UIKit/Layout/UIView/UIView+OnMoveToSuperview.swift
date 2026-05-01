//
//  UIView+OnMoveToSuperview.swift
//

import UIKit

nonisolated(unsafe) private var onMoveToSuperviewKey: UInt8 = 0

// MARK: - onMoveToSuperview
extension UIView {
    private var onMoveToSuperview: ViewHandler? {
        get { objc_getAssociatedObject(self, &onMoveToSuperviewKey) as? ViewHandler }
        set { _ = Self._installMoveToSuperview; objc_setAssociatedObject(self, &onMoveToSuperviewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Sets a handler to execute when the view moves to a superview and returns self (chainable).
    /// If the view already has a superview the handler fires immediately.
    @discardableResult public func onMoveToSuperview(_ onMoveToSuperview: @escaping ViewHandler) -> Self {
        if superview.isNotNil { onMoveToSuperview(self); return self }
        return with { $0.onMoveToSuperview = onMoveToSuperview }
    }

    /// Sets a handler to execute when the view moves to a superview and returns self (chainable).
    /// If the view already has a superview the handler fires immediately.
    @discardableResult public func onMoveToSuperview(_ onMoveToSuperview: @escaping ViewAndSuperviewHandler) -> Self {
        if let sv = superview { onMoveToSuperview((self, sv)); return self }
        return with {
            $0.onMoveToSuperview = {
                guard let superview = $0.superview else { return }
                onMoveToSuperview(($0, superview))
            }
        }
    }
}

// MARK: - onMoveToSuperview Swizzle
extension UIView {
    private static let _installMoveToSuperview: Void = {
        let cls = UIView.self
        guard let method = class_getInstanceMethod(cls, #selector(didMoveToSuperview)) else {
            return print("Could not get `didMoveToSuperview()` selector.")
        }
        guard let originalMethod = class_getInstanceMethod(cls, #selector(originalDidMoveToSuperview)) else {
            return print("Could not get original `originalDidMoveToSuperview()` selector.")
        }
        guard let swizzledMethod = class_getInstanceMethod(cls, #selector(swizzledDidMoveToSuperview)) else {
            return print("Could not get swizzled `swizzledDidMoveToSuperview()` selector.")
        }
        method_exchangeImplementations(method, originalMethod)
        method_exchangeImplementations(method, swizzledMethod)
    }()

    @objc private func originalDidMoveToSuperview() {}

    @objc private func swizzledDidMoveToSuperview() {
        originalDidMoveToSuperview()
        guard superview.isNotNil else { return }
        guard let handler = onMoveToSuperview else { return }
        handler(self)
        onMoveToSuperview = nil
    }
}
