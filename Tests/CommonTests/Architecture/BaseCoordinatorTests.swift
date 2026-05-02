//
//  BaseCoordinatorTests.swift
//

import UIKit
import XCTest
@testable import Common

@MainActor
final class BaseCoordinatorTests: XCTestCase {

    private class StubCoordinator: BaseCoordinator {
        var startCalled = false
        override func start() { startCalled = true }
    }

    /// Pushes `vc` onto `nav` by directly setting the viewControllers array (no animation),
    /// which triggers KVO synchronously — suitable for unit tests without a window.
    private func simulatePush(_ vc: UIViewController, onto nav: UINavigationController) {
        nav.viewControllers = nav.viewControllers + [vc]
    }

    /// Simulates a pop (swipe-back or programmatic) by removing the last VC from the stack.
    private func simulatePop(from nav: UINavigationController) {
        guard nav.viewControllers.count > 1 else { return }
        nav.viewControllers = Array(nav.viewControllers.dropLast())
    }

    private var nav: UINavigationController!
    private var parent: StubCoordinator!
    private var child: StubCoordinator!

    override func setUp() {
        super.setUp()
        nav = UINavigationController()
        parent = StubCoordinator(navigationController: nav)
        child = StubCoordinator(navigationController: nav)
    }

    override func tearDown() {
        parent = nil
        child = nil
        nav = nil
        super.tearDown()
    }

    // MARK: - addChild

    func test_addChild_setsChildParent() {
        parent.addChild(child)
        XCTAssertTrue(child.parent === parent)
    }

    func test_addChild_appendsToChildCoordinators() {
        parent.addChild(child)
        XCTAssertEqual(parent.childCoordinators.count, 1)
    }

    func test_addChild_deduplicatesSameInstance() {
        parent.addChild(child)
        parent.addChild(child)
        XCTAssertEqual(parent.childCoordinators.count, 1)
    }

    func test_addChildAndStart_callsStart() {
        parent.addChildAndStart(child)
        XCTAssertTrue(child.startCalled)
    }

    // MARK: - removeChild (identity-based)

    func test_removeChild_removesOnlyTargetInstance() {
        let child2 = StubCoordinator(navigationController: nav)
        parent.addChild(child)
        parent.addChild(child2)
        XCTAssertEqual(parent.childCoordinators.count, 2)

        parent.removeChild(child)

        XCTAssertEqual(parent.childCoordinators.count, 1)
        XCTAssertTrue(parent.childCoordinators.first === child2)
    }

    func test_removeChild_doesNotRemoveSameTypeOtherInstance() {
        let child2 = StubCoordinator(navigationController: nav)
        parent.addChild(child)
        parent.addChild(child2)

        // Removing child must NOT remove child2 (same type, different instance)
        parent.removeChild(child)
        XCTAssertFalse(parent.childCoordinators.isEmpty)
        XCTAssertTrue(parent.childCoordinators.first === child2)
    }

    // MARK: - finish()

    func test_finish_removesChildFromParent() {
        parent.addChild(child)
        child.finish()
        XCTAssertTrue(parent.childCoordinators.isEmpty)
    }

    func test_finish_callsOnPerformed() {
        var receivedCoordinator: (any Coordinator)?
        let tracked = StubCoordinator(navigationController: nav) { receivedCoordinator = $0 }
        parent.addChild(tracked)

        tracked.finish()

        XCTAssertTrue(receivedCoordinator === tracked)
    }

    func test_finish_isIdempotent_onPerformedFiredOnce() {
        var callCount = 0
        let tracked = StubCoordinator(navigationController: nav) { _ in callCount += 1 }
        parent.addChild(tracked)

        tracked.finish()
        tracked.finish()

        XCTAssertEqual(callCount, 1)
    }

    func test_finish_isIdempotent_childRemovedOnce() {
        parent.addChild(child)
        child.finish()
        child.finish()
        XCTAssertTrue(parent.childCoordinators.isEmpty)
    }

    func test_finish_withNoParent_callsOnPerformed() {
        var called = false
        let orphan = StubCoordinator(navigationController: nav) { _ in called = true }
        orphan.finish()
        XCTAssertTrue(called)
    }

    // MARK: - cancel()

    func test_cancel_removesChildFromParent() {
        parent.addChild(child)
        child.cancel()
        XCTAssertTrue(parent.childCoordinators.isEmpty)
    }

    func test_cancel_doesNotCallOnPerformed() {
        var called = false
        let tracked = StubCoordinator(navigationController: nav) { _ in called = true }
        parent.addChild(tracked)

        tracked.cancel()

        XCTAssertFalse(called)
    }

    func test_cancel_isIdempotent() {
        parent.addChild(child)
        child.cancel()
        child.cancel()
        XCTAssertTrue(parent.childCoordinators.isEmpty)
    }

    func test_finish_afterCancel_isNoOp() {
        var callCount = 0
        let tracked = StubCoordinator(navigationController: nav) { _ in callCount += 1 }
        parent.addChild(tracked)

        tracked.cancel()
        tracked.finish()  // must be a no-op — isFinished already true

        XCTAssertEqual(callCount, 0)
        XCTAssertTrue(parent.childCoordinators.isEmpty)
    }

    func test_cancel_afterFinish_isNoOp() {
        var callCount = 0
        let tracked = StubCoordinator(navigationController: nav) { _ in callCount += 1 }
        parent.addChild(tracked)

        tracked.finish()
        tracked.cancel()  // must be a no-op — isFinished already true

        XCTAssertEqual(callCount, 1)
        XCTAssertTrue(parent.childCoordinators.isEmpty)
    }

    // MARK: - KVO lifecycle tracking (gesture-driven cleanup)

    func test_kvo_popRemovesCoordinatorFromParent() {
        // A pushing coordinator: start() pushes one VC onto the shared nav stack.
        class PushingCoordinator: BaseCoordinator {
            let pushedVC = UIViewController()
            override func start() {
                navigationController.viewControllers =
                    navigationController.viewControllers + [pushedVC]
            }
        }

        let pushing = PushingCoordinator(navigationController: nav)
        parent.addChildAndStart(pushing)
        XCTAssertEqual(parent.childCoordinators.count, 1)

        // Simulate swipe-back / programmatic pop
        nav.viewControllers = Array(nav.viewControllers.dropLast())

        XCTAssertTrue(parent.childCoordinators.isEmpty,
                      "KVO should have triggered cancel() and removed coordinator from parent")
    }

    func test_kvo_popDoesNotFireOnPerformed() {
        class PushingCoordinator: BaseCoordinator {
            let pushedVC = UIViewController()
            override func start() {
                navigationController.viewControllers =
                    navigationController.viewControllers + [pushedVC]
            }
        }

        var called = false
        let pushing = PushingCoordinator(navigationController: nav) { _ in called = true }
        parent.addChildAndStart(pushing)

        nav.viewControllers = Array(nav.viewControllers.dropLast())

        XCTAssertFalse(called, "cancel() must not fire onPerformed")
    }

    func test_kvo_finishBeforePopSuppressesDoubleCleanup() {
        class PushingCoordinator: BaseCoordinator {
            let pushedVC = UIViewController()
            override func start() {
                navigationController.viewControllers =
                    navigationController.viewControllers + [pushedVC]
            }
        }

        var callCount = 0
        let pushing = PushingCoordinator(navigationController: nav) { _ in callCount += 1 }
        parent.addChildAndStart(pushing)

        pushing.finish()                                              // marks isFinished = true, stops tracking
        nav.viewControllers = Array(nav.viewControllers.dropLast())  // KVO fires but isFinished guard skips it

        XCTAssertEqual(callCount, 1)
        XCTAssertTrue(parent.childCoordinators.isEmpty)
    }

    func test_kvo_noTrackingWhenCoordinatorDoesNotPush() {
        // addChildAndStart on a coordinator that pushes nothing — no tracking wired, no crash.
        parent.addChildAndStart(child)  // StubCoordinator.start() does not push any VC

        // Mutating the stack must NOT trigger cancel on child
        let vc = UIViewController()
        simulatePush(vc, onto: nav)
        simulatePop(from: nav)

        XCTAssertEqual(parent.childCoordinators.count, 1,
                       "Non-pushing coordinator must not be removed by unrelated nav changes")
    }

    // MARK: - set() — re-anchoring and bootstrap

    func test_set_noFalseCancel_whenCoordinatorReplacesStack() {
        // Coordinator tracked on A, then replaces stack with D — must NOT cancel.
        class PushingCoordinator: BaseCoordinator {
            let pushedVC = UIViewController()
            override func start() {
                navigationController.viewControllers =
                    navigationController.viewControllers + [pushedVC]
            }
        }

        let pushing = PushingCoordinator(navigationController: nav)
        parent.addChildAndStart(pushing)

        let d = UIViewController()
        pushing.set([d])  // coordinator's own set() — must re-anchor, not cancel

        XCTAssertEqual(parent.childCoordinators.count, 1,
                       "Coordinator replacing its own stack must not be removed")
    }

    func test_set_reanchors_popNewVCTriggersCancelAfterSet() {
        // After set([D]) the coordinator must track D — popping D should cancel it.
        class PushingCoordinator: BaseCoordinator {
            let pushedVC = UIViewController()
            override func start() {
                navigationController.viewControllers =
                    navigationController.viewControllers + [pushedVC]
            }
        }

        let pushing = PushingCoordinator(navigationController: nav)
        parent.addChildAndStart(pushing)

        let d = UIViewController()
        pushing.set([d])
        XCTAssertEqual(parent.childCoordinators.count, 1)

        // Simulate pop of D (e.g. parent coordinator replaces stack)
        nav.viewControllers = nav.viewControllers.filter { $0 !== d }

        XCTAssertTrue(parent.childCoordinators.isEmpty,
                      "Pop of re-anchored VC must trigger cancel")
    }

    func test_set_bootstrapsTracking_whenNotPreviouslyTracked() {
        // Coordinator added via addChild (not addChildAndStart) — no tracking yet.
        // Calling set() should bootstrap tracking.
        parent.addChild(child)
        XCTAssertEqual(parent.childCoordinators.count, 1)

        let d = UIViewController()
        child.set([d])  // bootstraps tracking on d

        // Pop d — should trigger cancel
        nav.viewControllers = []

        XCTAssertTrue(parent.childCoordinators.isEmpty,
                      "set() on untracked coordinator should bootstrap tracking")
    }

    func test_set_emptyArray_cancels_whenTracked() {
        class PushingCoordinator: BaseCoordinator {
            let pushedVC = UIViewController()
            override func start() {
                navigationController.viewControllers =
                    navigationController.viewControllers + [pushedVC]
            }
        }

        let pushing = PushingCoordinator(navigationController: nav)
        parent.addChildAndStart(pushing)

        pushing.set([])  // empty set — tracked VC (pushedVC) leaves stack → cancel

        XCTAssertTrue(parent.childCoordinators.isEmpty,
                      "set([]) should be treated as flow abandonment")
    }

    // MARK: - terminate() shared by finish() and cancel()

    func test_terminate_finish_doesNotTriggerCancelOverride() {
        // Verifies finish() and cancel() are independent override points.
        // A subclass that overrides cancel() should NOT see that override run during finish().
        class TrackingCoordinator: BaseCoordinator {
            var cancelCallCount = 0
            override func cancel() { cancelCallCount += 1; super.cancel() }
        }

        let coord = TrackingCoordinator(navigationController: nav)
        parent.addChild(coord)

        coord.finish()

        XCTAssertEqual(coord.cancelCallCount, 0,
                       "finish() must not call the cancel() override")
    }
}
