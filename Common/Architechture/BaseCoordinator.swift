//
//  BaseCoordinator.swift
//

import UIKit

// MARK: - BaseCoordinator
open class BaseCoordinator: NSObject, Coordinator, CoordinatorParent, BaseModuleDelegate {
    public let navigationController: UINavigationController

    public init(navigationController: @autoclosure () -> UINavigationController) {
        self.navigationController = navigationController()
    }

    private var _childCoordinators: [Coordinator] = [] {
        didSet { Logger.log(["\(Self.self)": _childCoordinators]) }
    }

    private var childCoordinators: [Coordinator] {
        get { queue.sync { self._childCoordinators } }
        set { queue.async(flags: .barrier) { self._childCoordinators = newValue } }
    }

    private lazy var queue: DispatchQueue = .init(
        label: "\(Bundle.main.bundleIdentifier ?? "*").\(Self.self).queue",
        attributes: .concurrent
    )

    // MARK: - Coordinator
    open func start() {}


    // MARK: - BaseCoordinatorParent

    /// By default it removes the received coordinator from child coordinators.
    /// - parameter child: Coordinator that performed the current call
    open func onProcessDone(by child: some Coordinator) {
        Logger.log(["\(Self.self)": child])
        removeChild(child)
    }

    // MARK: - BaseModuleDelegate

    /// By default it dismisses the currently presented view controller, if there is any,
    open func onDismissRequested() { dismiss { Logger.log(["navigationController.viewControllers.count": self.navigationController.viewControllers.count]) } }

    /// By default it pops the top view controller from the navigation controller.
    open func onGoBackRequested() { pop(.back, animated: true) }
}

// MARK: - Convenience child coordinators methods
extension BaseCoordinator {
    public func addChild(coordinator: some Coordinator) {
        Logger.log(["\(Self.self)": coordinator])
        removeChild(coordinator)
        childCoordinators.append(coordinator)
    }

    public func addChildAndStart(coordinator: some Coordinator) {
        Logger.log(["\(Self.self)": coordinator])
        addChild(coordinator: coordinator)
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


// MARK: - Navigationable
extension BaseCoordinator: Navigationable {}
