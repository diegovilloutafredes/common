//
//  BaseCoordinator.swift
//

import UIKit

// MARK: - BaseCoordinator
// MARK: - BaseCoordinator

/// A base implementation of the `Coordinator` protocol that also conforms to `BaseModuleDelegate`.
/// It manages a `UINavigationController` and an optional completion handler.
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
}

// MARK: - Convenience child coordinators methods
extension BaseCoordinator {
    
    /// Adds a child coordinator to the list of managed child coordinators.
    /// - Parameter coordinator: The child coordinator to add.
    public func addChild(_ coordinator: some Coordinator) {
        Logger.log(["\(Self.self)": coordinator])
        removeChild(coordinator)
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

    /// Removes a child coordinator from the list of managed child coordinators.
    /// - Parameter coordinator: The child coordinator to remove.
    public func removeChild<T>(_ coordinator: T) where T: Coordinator {
        Logger.log(["\(Self.self)": coordinator])
        childCoordinators.removeAll(T.self)
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


// MARK: - Dismissable
extension BaseCoordinator: Presentable {}
