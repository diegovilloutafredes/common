//
//  UIView+LayoutSubviews.swift
//

import UIKit

nonisolated(unsafe) private var onLayoutSubviewsKey: UInt8 = 0

// MARK: - onLayoutSubviews
extension UIView {
    private var onLayoutSubviews: ViewHandler? {
        get { objc_getAssociatedObject(self, &onLayoutSubviewsKey) as? ViewHandler }
        set { _ = Self._installLayoutSubviews; objc_setAssociatedObject(self, &onLayoutSubviewsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Sets a handler to execute when layoutSubviews is called and returns self (chainable).
    /// - Parameter onLayoutSubviews: The handler to execute.
    @discardableResult public func onLayoutSubviews(_ onLayoutSubviews: @escaping ViewHandler) -> Self {
        with { $0.onLayoutSubviews = onLayoutSubviews }
    }
}

// MARK: - onLayoutSubviews Swizzle
extension UIView {
    private static let _installLayoutSubviews: Void = {
        let cls = UIView.self
        guard let method = class_getInstanceMethod(cls, #selector(layoutSubviews)) else {
            return print("Could not get `layoutSubviews()` selector.")
        }
        guard let originalMethod = class_getInstanceMethod(cls, #selector(originalLayoutSubviews)) else {
            return print("Could not get original `originalLayoutSubviews()` selector.")
        }
        guard let swizzledMethod = class_getInstanceMethod(cls, #selector(swizzledLayoutSubviews)) else {
            return print("Could not get swizzled `swizzledLayoutSubviews()` selector.")
        }
        method_exchangeImplementations(method, originalMethod)
        method_exchangeImplementations(method, swizzledMethod)
    }()

    @objc private func originalLayoutSubviews() {}

    @objc private func swizzledLayoutSubviews() {
        originalLayoutSubviews()
        guard let handler = onLayoutSubviews else { return }
        handler(self)
        onLayoutSubviews = nil
    }
}
