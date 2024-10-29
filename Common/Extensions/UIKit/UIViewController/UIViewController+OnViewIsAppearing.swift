//
//  UIViewController+OnViewIsAppearing.swift
//

import UIKit

// MARK: - onViewIsAppearing Swizzle
extension UIViewController {
    private var onViewIsAppearingAction: ViewControllerHandler? {
        get { associatedObject(for: "onViewIsAppearingAction") as? ViewControllerHandler }
        set { swizzleViewIsAppearingIfNeeded(); set(associatedObject: newValue, for: "onViewIsAppearingAction") }
    }

    @discardableResult public func onViewIsAppearing(_ onViewIsAppearing: @escaping ViewControllerHandler) -> Self {
        with { $0.onViewIsAppearingAction = onViewIsAppearing }
    }

    private static var notSwizzledViewIsAppearing = true
    @objc private func originalViewIsAppearing() {}

    @objc private func swizzledViewIsAppearing() {
        originalViewIsAppearing()
        if isViewLoaded { onViewIsAppearingAction?(self) }
    }

    private func swizzleViewIsAppearingIfNeeded() {
        guard Self.notSwizzledViewIsAppearing else { return }

        guard let viewControllerClass: AnyClass = object_getClass(self) else {
            return print("Could not get `UIViewController` class.")
        }

        let selector = #selector(viewIsAppearing(_:))
        guard let method = class_getInstanceMethod(viewControllerClass, selector) else {
            return print("Could not get `viewIsAppearing()` selector.")
        }

        let originalSelector = #selector(originalViewIsAppearing)
        guard let originalMethod = class_getInstanceMethod(viewControllerClass, originalSelector) else {
            return print("Could not get original `originalViewIsAppearing()` selector.")
        }

        let swizzledSelector = #selector(swizzledViewIsAppearing)
        guard let swizzledMethod = class_getInstanceMethod(viewControllerClass, swizzledSelector) else {
            return print("Could not get swizzled `swizzledViewIsAppearing()` selector.")
        }

        method_exchangeImplementations(method, originalMethod)
        method_exchangeImplementations(method, swizzledMethod)

        Self.notSwizzledViewIsAppearing = false
    }
}
