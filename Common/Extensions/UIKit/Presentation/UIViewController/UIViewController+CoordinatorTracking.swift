//
//  UIViewController+CoordinatorTracking.swift
//

import UIKit

// MARK: - Tracking box

/// Holds the tracking coordinator weakly — the view controller must never keep
/// its coordinator alive, and a finished coordinator must be free to deallocate.
@MainActor
private final class CoordinatorTrackingBox {
    weak var coordinator: BaseCoordinator?

    init(coordinator: BaseCoordinator) {
        self.coordinator = coordinator
    }
}

nonisolated(unsafe) private var coordinatorTrackingKey: UInt8 = 0

// MARK: - Registration

extension UIViewController {

    /// Registers `coordinator` to be notified when this view controller leaves
    /// its parent container — the moment a flow's entry screen is popped.
    ///
    /// Uses UIKit's view-controller containment callback rather than observing
    /// `UINavigationController.viewControllers`: KVO on that property fires only
    /// when it is *assigned*, so back-button, swipe-back, `popViewController`,
    /// and `popToViewController` removals go unreported.
    func trackRemoval(by coordinator: BaseCoordinator) {
        _ = Self._installCoordinatorTrackingSwizzle
        objc_setAssociatedObject(
            self,
            &coordinatorTrackingKey,
            CoordinatorTrackingBox(coordinator: coordinator),
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }

    /// Stops reporting this view controller's removal to any coordinator.
    func stopTrackingRemoval() {
        objc_setAssociatedObject(self, &coordinatorTrackingKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

// MARK: - Swizzle install (one-time, single selector)

extension UIViewController {

    /// Installs the `didMove(toParent:)` swizzle on first registration.
    /// Mirrors the install pattern in `UIViewController+LifecycleHooks`; kept
    /// separate so each swizzle site stays self-contained, and so coordinator
    /// tracking never competes for the single public lifecycle-hook slot.
    private static let _installCoordinatorTrackingSwizzle: Void = {
        let cls = UIViewController.self
        guard
            let originalMethod = class_getInstanceMethod(cls, #selector(didMove(toParent:))),
            let placeholderMethod = class_getInstanceMethod(cls, #selector(_originalDidMoveToParent(_:))),
            let swizzledMethod = class_getInstanceMethod(cls, #selector(_swizzledDidMoveToParent(_:)))
        else {
            return print("Could not resolve selectors to swizzle didMove(toParent:).")
        }
        method_exchangeImplementations(originalMethod, placeholderMethod)
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc private func _originalDidMoveToParent(_ parent: UIViewController?) {}

    @objc private func _swizzledDidMoveToParent(_ parent: UIViewController?) {
        _originalDidMoveToParent(parent)
        // Only removals matter; being added to a container is not a flow exit.
        guard parent == nil else { return }
        let box = objc_getAssociatedObject(self, &coordinatorTrackingKey) as? CoordinatorTrackingBox
        box?.coordinator?.trackedViewControllerDidLeaveContainer(self)
    }
}
