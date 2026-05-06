//
//  BaseCoordinator.swift
//

import UIKit

// MARK: - BaseCoordinator

/// A base implementation of the `Coordinator` protocol that also conforms to `BaseModuleDelegate`.
/// It manages a `UINavigationController` and an optional completion handler.
@MainActor
open class BaseCoordinator: NSObject, Coordinator, BaseModuleDelegate {
    
    /// The navigation controller used for navigation.
    public let navigationController: UINavigationController
    
    /// A handler called when the coordinator finishes its flow.
    public let onPerformed: Handler<Coordinator>?

    /// Initializes a new `BaseCoordinator`.
    /// - Parameters:
    ///   - navigationController: The navigation controller to use.
    ///   - onPerformed: An optional handler to be called when the coordinator finishes.
    public init(navigationController: UINavigationController, onPerformed: Handler<Coordinator>? = nil) {
        self.navigationController = navigationController
        self.onPerformed = onPerformed
    }

    /// A list of child coordinators managed by this coordinator.
    public var childCoordinators: [Coordinator] = []

    /// The parent coordinator that owns this coordinator. Set automatically by `addChild`.
    public weak var parent: BaseCoordinator?

    private var isFinished = false
    private weak var trackedViewController: UIViewController?
    private var viewControllersObservation: NSKeyValueObservation?

    // MARK: - Coordinator

    /// Starts the coordinator's flow.
    /// Subclasses must override this method to define their specific start logic.
    open func start() {}


    // MARK: - BaseModuleDelegate

    /// Handles a dismissal request.
    /// By default it dismisses the currently top most presented view controller, if there is any.
    open func onDismissRequested() { dismiss() }

    /// Handles a go back request.
    /// By default it pops the top view controller from the navigation controller.
    open func onGoBackRequested() { pop() }

    /// Completes this coordinator's flow: removes self from parent's child list, then fires `onPerformed`.
    /// Idempotent — safe to call multiple times; only the first call has effect.
    open func finish() {
        guard !isFinished else { return }
        terminate()
        onPerformed?(self)
    }

    /// Cancels this coordinator's flow without firing `onPerformed`.
    /// Called automatically when the coordinator's tracked entry VC leaves the nav stack (e.g. swipe-back).
    /// Idempotent — safe to call multiple times; only the first call has effect.
    open func cancel() {
        guard !isFinished else { return }
        terminate()
    }

    // MARK: - Lifecycle tracking

    private func terminate() {
        isFinished = true
        stopLifecycleTracking()
        parent?.removeChild(self)
    }

    private func beginLifecycleTracking(for viewController: UIViewController) {
        trackedViewController = viewController
        viewControllersObservation = navigationController.observe(
            \.viewControllers,
            options: [.new]
        ) { [weak self] _, change in
            // UIKit delivers nav-stack KVO on the main thread; assert that to the
            // type system so the MainActor-isolated property/method access is sound.
            // Crashes (rather than silently corrupts) if a future caller delivers off-main.
            MainActor.assumeIsolated {
                guard
                    let self,
                    let tracked = self.trackedViewController,
                    !(change.newValue ?? []).contains(tracked)
                else { return }
                self.cancel()
            }
        }
    }

    private func stopLifecycleTracking() {
        viewControllersObservation = nil
        trackedViewController = nil
    }
}

// MARK: - Convenience child coordinators methods
extension BaseCoordinator {
    
    /// Adds a child coordinator to the list of managed child coordinators.
    /// - Parameter coordinator: The child coordinator to add.
    public func addChild(_ coordinator: some Coordinator) {
        Logger.log(["\(Self.self)": coordinator])
        removeChild(coordinator)
        (coordinator as? BaseCoordinator)?.parent = self
        childCoordinators.append(coordinator)
    }

    /// Adds a child coordinator and starts it immediately.
    /// Automatically tracks the first VC the coordinator pushes so that a swipe-back gesture
    /// triggers `cancel()` and removes the coordinator from the child list.
    /// - Parameter coordinator: The child coordinator to add and start.
    public func addChildAndStart(_ coordinator: some Coordinator) {
        Logger.log(["\(Self.self)": coordinator])
        addChild(coordinator)
        let preStack = navigationController.viewControllers
        coordinator.start()
        let postStack = navigationController.viewControllers
        if let entry = postStack.first(where: { !preStack.contains($0) }),
           let base = coordinator as? BaseCoordinator {
            base.beginLifecycleTracking(for: entry)
        }
    }

    /// Retrieves the first child coordinator of a specific type.
    /// - Parameter type: The type of the child coordinator to retrieve.
    /// - Returns: The first child coordinator matching the type, or `nil` if not found.
    public func getChild<T>(_ type: T.Type) -> T? where T: Coordinator {
        Logger.log(["\(Self.self)": type])
        return childCoordinators.getFirst(type)
    }

    /// Removes a specific child coordinator by identity.
    /// - Parameter coordinator: The exact coordinator instance to remove.
    public func removeChild<T>(_ coordinator: T) where T: Coordinator {
        Logger.log(["\(Self.self)": coordinator])
        childCoordinators.removeAll { $0 === coordinator }
    }
}

// MARK: - ActivityIndicatorable
extension BaseCoordinator: ActivityIndicatorable {}


// MARK: - AlertPresentable
extension BaseCoordinator: AlertPresentable {}


// MARK: - Dismissable
extension BaseCoordinator: Dismissable {}


// MARK: - Navigationable
extension BaseCoordinator: Navigationable {

    /// Replaces the nav stack with the given array and re-anchors lifecycle tracking.
    ///
    /// Two cases handled transparently:
    /// - Tracking already active (started via `addChildAndStart`): `trackedViewController` is updated
    ///   to the new first VC **before** calling `setViewControllers`, because KVO fires synchronously
    ///   inside that call. Updating after would be too late — the old tracked VC would already be
    ///   gone and `cancel()` would have fired incorrectly.
    /// - Tracking not yet active (coordinator added via `addChild` alone): tracking is bootstrapped
    ///   after the nav call, since no observer exists to false-fire during it.
    ///
    /// `set([])` intentionally lets existing tracking fire `cancel()` — an empty-stack replacement
    /// is treated as flow abandonment.
    public func set(_ viewControllers: [UIViewController], animated: Bool = false) {
        guard let first = viewControllers.first else {
            // UIKit silently ignores setViewControllers([]) so KVO never fires.
            // Treat empty replacement as explicit flow abandonment.
            navigationController.setViewControllers([], animated: animated)
            cancel()
            return
        }
        // Re-anchor BEFORE the nav call — KVO fires synchronously inside setViewControllers,
        // and the guard checks whether trackedViewController is still in the new stack.
        trackedViewController = first
        navigationController.setViewControllers(viewControllers, animated: animated)
        if viewControllersObservation == nil, !isFinished {
            beginLifecycleTracking(for: first)
        }
    }

    public func set(_ viewController: UIViewController, animated: Bool = false) {
        set([viewController], animated: animated)
    }
}


// MARK: - Presentable
extension BaseCoordinator: Presentable {}
