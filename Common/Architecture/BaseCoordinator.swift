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
        isFinished = true
        parent?.removeChild(self)
        onPerformed?(self)
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
    /// - Parameter coordinator: The child coordinator to add and start.
    public func addChildAndStart(_ coordinator: some Coordinator) {
        Logger.log(["\(Self.self)": coordinator])
        addChild(coordinator)
        coordinator.start()
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
extension BaseCoordinator: Navigationable {}


// MARK: - Presentable
extension BaseCoordinator: Presentable {}
