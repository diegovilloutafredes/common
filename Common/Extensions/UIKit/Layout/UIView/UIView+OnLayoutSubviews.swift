//
//  UIView+LayoutSubviews.swift
//

import UIKit

nonisolated(unsafe) private var onLayoutSubviewsKey: UInt8 = 0
nonisolated(unsafe) private var pillBehaviorKey: UInt8 = 0
nonisolated(unsafe) private var pillCornersKey: UInt8 = 0

// MARK: - onLayoutSubviews
extension UIView {
    private var onLayoutSubviewsHandlers: [ViewHandler] {
        get { (objc_getAssociatedObject(self, &onLayoutSubviewsKey) as? [ViewHandler]) ?? [] }
        set {
            _ = Self._installLayoutSubviews
            objc_setAssociatedObject(self, &onLayoutSubviewsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Queue a one-shot handler that fires on the next `layoutSubviews` pass.
    ///
    /// Multiple handlers may be queued on the same view; each fires once in
    /// registration order then is removed from the queue. A handler may safely
    /// queue further handlers from within its own body — those fire on the
    /// *next* pass, not the current one.
    /// - Parameter onLayoutSubviews: The handler to execute.
    @discardableResult public func onLayoutSubviews(_ onLayoutSubviews: @escaping ViewHandler) -> Self {
        with { $0.onLayoutSubviewsHandlers.append(onLayoutSubviews) }
    }
}

// MARK: - Persistent pill behavior (internal)
extension UIView {
    /// When `true`, the view's `cornerRadius` is updated to `bounds.height / 2`
    /// on every layout pass for the lifetime of the view, keeping a perfect
    /// pill shape across resize and rotation. Settable only through
    /// `setAsRoundedView(radius: nil)`.
    internal var _pillBehavior: Bool {
        get { (objc_getAssociatedObject(self, &pillBehaviorKey) as? Bool) ?? false }
        set {
            _ = Self._installLayoutSubviews
            objc_setAssociatedObject(self, &pillBehaviorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// The `CACornerMask` to apply while `_pillBehavior` is `true`.
    internal var _pillCorners: CACornerMask {
        get {
            let raw = (objc_getAssociatedObject(self, &pillCornersKey) as? UInt) ?? CACornerMask.all.rawValue
            return CACornerMask(rawValue: raw)
        }
        set {
            _ = Self._installLayoutSubviews
            objc_setAssociatedObject(self, &pillCornersKey, newValue.rawValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
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
        applyPillIfNeeded()
        drainOnLayoutSubviewsQueue()
    }

    // Pill state lives in its own storage (not in the one-shot handler queue),
    // so it can never be clobbered by a caller using `onLayoutSubviews { }` and
    // is always applied at the right moment in the layout cycle.
    private func applyPillIfNeeded() {
        guard _pillBehavior, bounds.height > 0 else { return }
        let radius = bounds.height / 2
        if layer.cornerRadius != radius { layer.cornerRadius = radius }
        if layer.maskedCorners != _pillCorners { layer.maskedCorners = _pillCorners }
    }

    // Snapshot first, clear second, fire third — so a handler that queues a
    // further handler inside its own body sees the new handler picked up on
    // the next pass rather than re-entering this one.
    private func drainOnLayoutSubviewsQueue() {
        let queued = onLayoutSubviewsHandlers
        guard !queued.isEmpty else { return }
        onLayoutSubviewsHandlers = []
        queued.forEach { $0(self) }
    }
}
