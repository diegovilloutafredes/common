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

    /// The controller this coordinator's presentations, dismissals and alerts go through (`PresentationAnchorProviding`).
    ///
    /// `nil`, the default, keeps the usual targets: the navigation controller for presentations and dismissals, and
    /// the application's top-most controller for alerts. Override it to move them, for example onto a controller
    /// this coordinator doesn't own.
    open var presentationAnchor: UIViewController? { nil }

    /// Whether this coordinator's flow has ended, through `finish()` or `cancel()`.
    ///
    /// Both ignore every call after the first, but an override runs its own code on every call: guard that code with
    /// `isFinished` when it must run once.
    public private(set) var isFinished = false
    private weak var trackedViewController: UIViewController?
    /// Set on a child started with `presentChild`: the sheet its flow runs in.
    fileprivate var presentedFlow: PresentedFlow?

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
    /// For a child started with `presentChild`, `onPerformed` fires once its sheet has been dismissed.
    open func finish() {
        guard !isFinished else { return }
        terminate { [self] in onPerformed?(self) }
    }

    /// Cancels this coordinator's flow without firing `onPerformed`.
    /// Called automatically when the coordinator's tracked entry view controller leaves the
    /// navigation stack — back button, swipe-back, `pop()`, `pop(.to(_:))`, or stack replacement.
    /// Idempotent — safe to call multiple times; only the first call has effect.
    open func cancel() {
        guard !isFinished else { return }
        terminate()
    }

    // MARK: - Lifecycle tracking

    private func terminate(then completion: (() -> Void)? = nil) {
        isFinished = true
        stopLifecycleTracking()
        cancelChildren()
        parent?.removeChild(self)
        endPresentedFlow(then: completion)
    }

    /// Dismisses the sheet of a child started with `presentChild`, with anything presented over it, then runs
    /// `completion`, which keeps this coordinator alive until then. Runs `completion` at once when there is no sheet
    /// to dismiss, or when an ending ancestor's own dismissal takes this sheet with it.
    private func endPresentedFlow(then completion: (() -> Void)?) {
        guard let presentedFlow, !isCoveredByAnEndingAncestor else {
            completion?()
            return
        }
        presentedFlow.dismiss(navigationController, then: completion)
    }

    /// Whether an ancestor that is ending is about to dismiss its own sheet, which takes this one with it. The
    /// ancestor dismisses after its children end; had this sheet started its own dismissal, UIKit would refuse the
    /// ancestor's while that one runs.
    private var isCoveredByAnEndingAncestor: Bool {
        var ancestor = parent
        while let current = ancestor {
            if current.isFinished, current.presentedFlow != nil, current.navigationController.presentingViewController != nil {
                return true
            }
            ancestor = current.parent
        }
        return false
    }

    /// Abandoning a flow abandons everything it started.
    ///
    /// Child coordinators are retained only by `childCoordinators`, so without
    /// this they would simply deallocate — never observing their own
    /// cancellation, silently skipping whatever their `cancel()` override does.
    /// It also makes multi-level teardown order-independent: whichever
    /// coordinator in a popped subtree is notified first tears down the rest.
    private func cancelChildren() {
        // Snapshot and clear first: each child's terminate() calls back into
        // removeChild on this coordinator.
        let children = childCoordinators
        childCoordinators = []
        children.forEach { ($0 as? BaseCoordinator)?.cancel() }
    }

    /// Tracks `viewController` so this coordinator cancels itself when that
    /// screen leaves the navigation stack.
    ///
    /// Tracking rides UIKit's view-controller containment callback, which is
    /// delivered for every removal path — back button, swipe-back,
    /// `popViewController`, `popToViewController`, and stack assignment.
    private func beginLifecycleTracking(for viewController: UIViewController) {
        trackedViewController = viewController
        viewController.trackRemoval(by: self)
    }

    private func stopLifecycleTracking() {
        trackedViewController?.stopTrackingRemoval()
        trackedViewController = nil
    }

    /// Called by the containment hook when a tracked screen leaves its container.
    /// Ignores view controllers this coordinator no longer tracks, which is what
    /// lets `set(_:)` re-anchor mid-flight without a false cancel.
    func trackedViewControllerDidLeaveContainer(_ viewController: UIViewController) {
        guard !isFinished, trackedViewController === viewController else { return }
        cancel()
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
    /// Automatically tracks the first view controller the coordinator pushes, so any removal of
    /// that screen — back button, swipe-back, or a programmatic pop — triggers `cancel()` and
    /// removes the coordinator from the child list. Requires no ViewController-side code.
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

    /// Adds `coordinator` as a child, starts it, and presents its navigation controller modally over what is on
    /// screen, from this coordinator's presentation target: `presentationAnchor`, or else the top-most controller its
    /// navigation controller presents.
    ///
    /// The child gets the lifecycle a pushed child has, with no code in either coordinator:
    /// - Swiping its sheet down cancels it.
    /// - Whenever its flow ends, through `finish()` or `cancel()`, its sheet is dismissed with anything presented
    ///   over it. After `finish()`, its `onPerformed` runs once the sheet is gone, so the parent can present its next
    ///   screen there and never dismisses the sheet itself.
    /// - A child that ends during `start()` is never presented.
    ///
    /// Style the sheet (`modalPresentationStyle`, detents) in the child's `start()`, which runs before it is
    /// presented. End a flow outside its own transitions: a dismissal UIKit refuses, because the flow is presenting or
    /// dismissing something at that moment, leaves the sheet up and `onPerformed` unsent.
    /// - Parameters:
    ///   - coordinator: The child. Its navigation controller becomes the sheet.
    ///   - animated: Whether the sheet is presented, and later dismissed, with an animation.
    public func presentChild(_ coordinator: BaseCoordinator, animated: Bool = true) {
        Logger.log(["\(Self.self)": coordinator])
        addChild(coordinator)
        coordinator.start()
        guard !coordinator.isFinished else { return }
        let flow = PresentedFlow(coordinator: coordinator, animated: animated)
        coordinator.presentedFlow = flow
        flow.present(from: self)
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
    /// The outgoing screen's registration is cleared **before** the nav call: UIKit
    /// reports its removal synchronously inside `setViewControllers`, and an
    /// outgoing screen that still pointed here would cancel the flow this call is
    /// re-rooting. Tracking then follows the new first view controller — whether or
    /// not it was active before, so a coordinator added via `addChild` alone is
    /// bootstrapped here too.
    ///
    /// A descendant re-rooting the stack (a child flow's login → `set(home)`) is not
    /// its ancestors abandoning their flows: an ancestor whose tracked screen is not
    /// in the new stack stops tracking it, rather than cancelling — and, through its
    /// cascade, cancelling this coordinator. Such an ancestor no longer cancels itself
    /// when a screen leaves; it ends through `finish()`, its own `set(_:)`, or its
    /// parent's cancellation.
    ///
    /// `set([])` explicitly cancels — an empty-stack replacement is flow abandonment.
    public func set(_ viewControllers: [UIViewController], animated: Bool = false) {
        guard let first = viewControllers.first else {
            navigationController.setViewControllers([], animated: animated)
            cancel()
            return
        }
        trackedViewController?.stopTrackingRemoval()
        trackedViewController = first
        var ancestor = parent
        while let current = ancestor {
            if let tracked = current.trackedViewController, !viewControllers.contains(where: { $0 === tracked }) {
                current.stopLifecycleTracking()
            }
            ancestor = current.parent
        }
        navigationController.setViewControllers(viewControllers, animated: animated)
        if !isFinished {
            beginLifecycleTracking(for: first)
        }
    }

    public func set(_ viewController: UIViewController, animated: Bool = false) {
        set([viewController], animated: animated)
    }
}


// MARK: - Presentable
extension BaseCoordinator: Presentable {}


// MARK: - PresentationAnchorProviding
extension BaseCoordinator: PresentationAnchorProviding {}


// MARK: - PresentedFlow

/// The sheet a child started with `presentChild` runs in. The child retains it, and it refers back weakly. It is the
/// sheet's presentation controller delegate, so `BaseCoordinator` needn't adopt that protocol, which subclasses may.
@MainActor
private final class PresentedFlow: NSObject, UIAdaptivePresentationControllerDelegate {

    private weak var coordinator: BaseCoordinator?
    /// Used for the presentation and for the dismissal that ends the flow.
    private let animated: Bool
    /// Set while UIKit presents the sheet: a dismissal requested then waits for the presentation to complete,
    /// because UIKit ignores one requested mid-transition.
    private var isPresenting = false
    private var dismissalAfterPresentation: (() -> Void)?

    init(coordinator: BaseCoordinator, animated: Bool) {
        self.coordinator = coordinator
        self.animated = animated
    }

    func present(from parent: BaseCoordinator) {
        guard let navigation = coordinator?.navigationController else { return }
        navigation.presentationController?.delegate = self
        isPresenting = true
        // The completion keeps this object alive until the presentation completes, so a dismissal waiting on it
        // still runs when the ended flow has already released it.
        parent.present(.overCurrent, viewController: navigation, animated: animated) { self.presentationDidComplete() }
    }

    /// Dismisses the sheet, with anything presented over it, then runs `completion`. Runs it at once when the sheet
    /// isn't presented: never presented, refused by UIKit, or already swiped away.
    func dismiss(_ navigation: UINavigationController, then completion: (() -> Void)?) {
        guard let presenter = navigation.presentingViewController else {
            completion?()
            return
        }
        let dismissal = { [animated] in presenter.dismiss(animated: animated) { completion?() } }
        if isPresenting {
            dismissalAfterPresentation = dismissal
        } else {
            dismissal()
        }
    }

    /// UIKit sends this only for an interactive dismissal: the sheet is already gone, so the flow is abandoned.
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        coordinator?.cancel()
    }

    private func presentationDidComplete() {
        isPresenting = false
        dismissalAfterPresentation?()
        dismissalAfterPresentation = nil
    }
}
