//
//  BaseCoordinator.swift
//

import UIKit

// MARK: - BaseCoordinator
open class BaseCoordinator: NSObject, Coordinator, BaseModuleDelegate {
    public let navigationController: UINavigationController
    public let onPerformed: Handler<Coordinator>?

    public init(navigationController: UINavigationController, onPerformed: Handler<Coordinator>? = nil) {
        self.navigationController = navigationController
        self.onPerformed = onPerformed
    }

    public var childCoordinators: [Coordinator] = []

    // MARK: - Coordinator
    open func start() {}


    // MARK: - BaseModuleDelegate

    /// By default it dismisses the currently top most presented view controller, if there is any,
    open func onDismissRequested() { dismiss() }

    /// By default it pops the top view controller from the navigation controller.
    open func onGoBackRequested() { pop() }
}

// MARK: - Convenience child coordinators methods
extension BaseCoordinator {
    public func addChild(_ coordinator: some Coordinator) {
        Logger.log(["\(Self.self)": coordinator])
        removeChild(coordinator)
        childCoordinators.append(coordinator)
    }

    public func addChildAndStart(_ coordinator: some Coordinator) {
        Logger.log(["\(Self.self)": coordinator])
        addChild(coordinator)
        coordinator.start()
    }

    public func getChild<T>(_ type: T.Type) -> T? where T: Coordinator {
        Logger.log(["\(Self.self)": type])
        return childCoordinators.getFirst(type)
    }

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
