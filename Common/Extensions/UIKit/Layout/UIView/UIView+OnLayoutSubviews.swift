//
//  UIView+LayoutSubviews.swift
//

import UIKit

// MARK: - onMoveToSuperview
extension UIView {
    private var onLayoutSubviews: ViewHandler? {
        get { associatedObject(for: "onLayoutSubviews") as? ViewHandler }
        set { swizzleIfNeeded(); set(associatedObject: newValue, for: "onLayoutSubviews") }
    }

    /// Sets a handler to execute when layoutSubviews is called and returns self (chainable).
    /// - Parameter onLayoutSubviews: The handler to execute.
    @discardableResult public func onLayoutSubviews(_ onLayoutSubviews: @escaping ViewHandler) -> Self {
        with { $0.onLayoutSubviews = onLayoutSubviews }
    }
}

// MARK: - onLayoutSubviews Swizzle
extension UIView {
    private static var notSwizzled = true

    @objc private func originalLayoutSubviews() {}

    @objc private func swizzledLayoutSubviews() {
        originalLayoutSubviews()
        onLayoutSubviews?(self)
        onLayoutSubviews = nil
    }

    private func swizzleIfNeeded() {
        guard Self.notSwizzled else { return }

        guard let viewClass: AnyClass = object_getClass(self) else {
            return print("Could not get `UIView` class.")
        }

        let selector = #selector(layoutSubviews)

        guard let method = class_getInstanceMethod(viewClass, selector) else {
            return print("Could not get `layoutSubviews()` selector.")
        }

        let originalSelector = #selector(originalLayoutSubviews)

        guard let originalMethod = class_getInstanceMethod(viewClass, originalSelector) else {
            return print("Could not get original `originalLayoutSubviews()` selector.")
        }

        let swizzledSelector = #selector(swizzledLayoutSubviews)

        guard let swizzledMethod = class_getInstanceMethod(viewClass, swizzledSelector) else {
            return print("Could not get swizzled `swizzledLayoutSubviews()` selector.")
        }

        method_exchangeImplementations(method, originalMethod)
        method_exchangeImplementations(method, swizzledMethod)

        Self.notSwizzled = false
    }
}
