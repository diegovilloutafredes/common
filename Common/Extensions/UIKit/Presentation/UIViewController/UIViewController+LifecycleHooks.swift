//
//  UIViewController+LifecycleHooks.swift
//

import UIKit

// MARK: - Hooks holder

@MainActor
private final class LifecycleHooks {
    var onViewDidLoad: Handler<UIViewController>?
    var onViewWillAppear: Handler<UIViewController>?
    var onViewIsAppearing: Handler<UIViewController>?
    var onViewDidAppear: Handler<UIViewController>?
    var onViewWillDisappear: Handler<UIViewController>?
    var onViewDidDisappear: Handler<UIViewController>?
}

nonisolated(unsafe) private var lifecycleHooksKey: UInt8 = 0

// MARK: - Public chainable setters

extension UIViewController {

    /// Sets a closure to be executed when `viewDidLoad` is called and returns self (chainable).
    /// - Parameter onViewDidLoad: The closure to execute.
    @discardableResult public func onViewDidLoad(_ onViewDidLoad: @escaping Handler<UIViewController>) -> Self {
        with { $0.lifecycleHooks().onViewDidLoad = onViewDidLoad }
    }

    /// Sets a closure to be executed when `viewWillAppear` is called and returns self (chainable).
    /// - Parameter onViewWillAppear: The closure to execute.
    @discardableResult public func onViewWillAppear(_ onViewWillAppear: @escaping Handler<UIViewController>) -> Self {
        with { $0.lifecycleHooks().onViewWillAppear = onViewWillAppear }
    }

    /// Sets a closure to be executed when `viewIsAppearing` is called and returns self (chainable).
    /// - Parameter onViewIsAppearing: The closure to execute.
    @discardableResult public func onViewIsAppearing(_ onViewIsAppearing: @escaping Handler<UIViewController>) -> Self {
        with { $0.lifecycleHooks().onViewIsAppearing = onViewIsAppearing }
    }

    /// Sets a closure to be executed when `viewDidAppear` is called and returns self (chainable).
    /// - Parameter onViewDidAppear: The closure to execute.
    @discardableResult public func onViewDidAppear(_ onViewDidAppear: @escaping Handler<UIViewController>) -> Self {
        with { $0.lifecycleHooks().onViewDidAppear = onViewDidAppear }
    }

    /// Sets a closure to be executed when `viewWillDisappear` is called and returns self (chainable).
    /// - Parameter onViewWillDisappear: The closure to execute.
    @discardableResult public func onViewWillDisappear(_ onViewWillDisappear: @escaping Handler<UIViewController>) -> Self {
        with { $0.lifecycleHooks().onViewWillDisappear = onViewWillDisappear }
    }

    /// Sets a closure to be executed when `viewDidDisappear` is called and returns self (chainable).
    /// - Parameter onViewDidDisappear: The closure to execute.
    @discardableResult public func onViewDidDisappear(_ onViewDidDisappear: @escaping Handler<UIViewController>) -> Self {
        with { $0.lifecycleHooks().onViewDidDisappear = onViewDidDisappear }
    }

    private func lifecycleHooks() -> LifecycleHooks {
        _ = Self._installLifecycleSwizzles
        if let existing = objc_getAssociatedObject(self, &lifecycleHooksKey) as? LifecycleHooks {
            return existing
        }
        let hooks = LifecycleHooks()
        objc_setAssociatedObject(self, &lifecycleHooksKey, hooks, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return hooks
    }
}

// MARK: - Swizzle install (one-time, all six events)

extension UIViewController {

    /// Installs swizzles for all six lifecycle methods on first hook registration.
    /// All events install together — VCs that never set a hook still pay the per-call indirection.
    private static let _installLifecycleSwizzles: Void = {
        installSwizzle(for: #selector(viewDidLoad), placeholder: #selector(_originalViewDidLoad), swizzled: #selector(_swizzledViewDidLoad))
        installSwizzle(for: #selector(viewWillAppear(_:)), placeholder: #selector(_originalViewWillAppear(_:)), swizzled: #selector(_swizzledViewWillAppear(_:)))
        installSwizzle(for: #selector(viewIsAppearing(_:)), placeholder: #selector(_originalViewIsAppearing(_:)), swizzled: #selector(_swizzledViewIsAppearing(_:)))
        installSwizzle(for: #selector(viewDidAppear(_:)), placeholder: #selector(_originalViewDidAppear(_:)), swizzled: #selector(_swizzledViewDidAppear(_:)))
        installSwizzle(for: #selector(viewWillDisappear(_:)), placeholder: #selector(_originalViewWillDisappear(_:)), swizzled: #selector(_swizzledViewWillDisappear(_:)))
        installSwizzle(for: #selector(viewDidDisappear(_:)), placeholder: #selector(_originalViewDidDisappear(_:)), swizzled: #selector(_swizzledViewDidDisappear(_:)))
    }()

    private static func installSwizzle(for original: Selector, placeholder: Selector, swizzled: Selector) {
        let cls = UIViewController.self
        guard
            let originalMethod = class_getInstanceMethod(cls, original),
            let placeholderMethod = class_getInstanceMethod(cls, placeholder),
            let swizzledMethod = class_getInstanceMethod(cls, swizzled)
        else {
            return print("Could not resolve selectors to swizzle \(original).")
        }
        method_exchangeImplementations(originalMethod, placeholderMethod)
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    @objc private func _originalViewDidLoad() {}
    @objc private func _swizzledViewDidLoad() {
        _originalViewDidLoad()
        if isViewLoaded {
            (objc_getAssociatedObject(self, &lifecycleHooksKey) as? LifecycleHooks)?.onViewDidLoad?(self)
        }
    }

    @objc private func _originalViewWillAppear(_ animated: Bool) {}
    @objc private func _swizzledViewWillAppear(_ animated: Bool) {
        _originalViewWillAppear(animated)
        if isViewLoaded {
            (objc_getAssociatedObject(self, &lifecycleHooksKey) as? LifecycleHooks)?.onViewWillAppear?(self)
        }
    }

    @objc private func _originalViewIsAppearing(_ animated: Bool) {}
    @objc private func _swizzledViewIsAppearing(_ animated: Bool) {
        _originalViewIsAppearing(animated)
        if isViewLoaded {
            (objc_getAssociatedObject(self, &lifecycleHooksKey) as? LifecycleHooks)?.onViewIsAppearing?(self)
        }
    }

    @objc private func _originalViewDidAppear(_ animated: Bool) {}
    @objc private func _swizzledViewDidAppear(_ animated: Bool) {
        _originalViewDidAppear(animated)
        if isViewLoaded {
            (objc_getAssociatedObject(self, &lifecycleHooksKey) as? LifecycleHooks)?.onViewDidAppear?(self)
        }
    }

    @objc private func _originalViewWillDisappear(_ animated: Bool) {}
    @objc private func _swizzledViewWillDisappear(_ animated: Bool) {
        _originalViewWillDisappear(animated)
        if isViewLoaded {
            (objc_getAssociatedObject(self, &lifecycleHooksKey) as? LifecycleHooks)?.onViewWillDisappear?(self)
        }
    }

    @objc private func _originalViewDidDisappear(_ animated: Bool) {}
    @objc private func _swizzledViewDidDisappear(_ animated: Bool) {
        _originalViewDidDisappear(animated)
        if isViewLoaded {
            (objc_getAssociatedObject(self, &lifecycleHooksKey) as? LifecycleHooks)?.onViewDidDisappear?(self)
        }
    }
}
