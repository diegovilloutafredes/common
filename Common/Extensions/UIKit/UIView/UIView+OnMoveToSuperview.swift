//
//  UIView+OnMoveToSuperview.swift
//

import UIKit

// MARK: - onMoveToSuperview
extension UIView {
    private var onMoveToSuperview: ViewHandler? {
        get { associatedObject(for: "onMoveToSuperview") as? ViewHandler }
        set { swizzleIfNeeded(); set(associatedObject: newValue, for: "onMoveToSuperview") }
    }

    @discardableResult public func onMoveToSuperview(_ onMoveToSuperview: @escaping ViewHandler) -> Self {
        with { $0.onMoveToSuperview = onMoveToSuperview }
    }

    @discardableResult public func onMoveToSuperview(_ onMoveToSuperview: @escaping ViewAndSuperviewHandler) -> Self {
        with {
            $0.onMoveToSuperview = {
                guard let superview = $0.superview else { return }
                onMoveToSuperview(($0, superview))
            }
        }
    }
}

// MARK: - onMoveToSuperview Swizzle
extension UIView {
    private static var notSwizzled = true

    @objc private func originalDidMoveToSuperview() {}

    @objc private func swizzledDidMoveToSuperview() {
        originalDidMoveToSuperview()
        guard superview.isNotNil else { return }
        onMoveToSuperview?(self)
        onMoveToSuperview = nil
    }

    private func swizzleIfNeeded() {
        guard Self.notSwizzled else { return }

        guard let viewClass: AnyClass = object_getClass(self) else {
            return print("Could not get `UIView` class.")
        }

        let selector = #selector(didMoveToSuperview)
        
        guard let method = class_getInstanceMethod(viewClass, selector) else {
            return print("Could not get `didMoveToSuperview()` selector.")
        }

        let originalSelector = #selector(originalDidMoveToSuperview)
        
        guard let originalMethod = class_getInstanceMethod(viewClass, originalSelector) else {
            return print("Could not get original `originalDidMoveToSuperview()` selector.")
        }

        let swizzledSelector = #selector(swizzledDidMoveToSuperview)
        
        guard let swizzledMethod = class_getInstanceMethod(viewClass, swizzledSelector) else {
            return print("Could not get swizzled `swizzledDidMoveToSuperview()` selector.")
        }

        method_exchangeImplementations(method, originalMethod)
        method_exchangeImplementations(method, swizzledMethod)

        Self.notSwizzled = false
    }
}
