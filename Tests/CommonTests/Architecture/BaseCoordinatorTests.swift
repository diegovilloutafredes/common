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

    /// Pushes one VC onto the shared nav stack and begins tracking it.
    private class PushingCoordinator: BaseCoordinator {
        let pushedVC = UIViewController()
        override func start() {
            navigationController.viewControllers =
                navigationController.viewControllers + [pushedVC]
        }
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
        let pushing = PushingCoordinator(navigationController: nav)
        parent.addChildAndStart(pushing)
        XCTAssertEqual(parent.childCoordinators.count, 1)

        nav.viewControllers = Array(nav.viewControllers.dropLast())

        XCTAssertTrue(parent.childCoordinators.isEmpty,
                      "KVO should have triggered cancel() and removed coordinator from parent")
    }

    func test_kvo_popDoesNotFireOnPerformed() {
        var called = false
        let pushing = PushingCoordinator(navigationController: nav) { _ in called = true }
        parent.addChildAndStart(pushing)

        nav.viewControllers = Array(nav.viewControllers.dropLast())

        XCTAssertFalse(called, "cancel() must not fire onPerformed")
    }

    func test_kvo_finishBeforePopSuppressesDoubleCleanup() {
        var callCount = 0
        let pushing = PushingCoordinator(navigationController: nav) { _ in callCount += 1 }
        parent.addChildAndStart(pushing)

        pushing.finish()                                              // marks isFinished = true, stops tracking
        nav.viewControllers = Array(nav.viewControllers.dropLast())  // KVO fires but isFinished guard skips it

        XCTAssertEqual(callCount, 1)
        XCTAssertTrue(parent.childCoordinators.isEmpty)
    }

    func test_kvo_noTrackingWhenCoordinatorDoesNotPush() {
        parent.addChildAndStart(child)  // StubCoordinator.start() does not push any VC

        // Unrelated nav mutations must not affect an untracked coordinator.
        nav.viewControllers = [UIViewController()]
        nav.viewControllers = []

        XCTAssertEqual(parent.childCoordinators.count, 1,
                       "Non-pushing coordinator must not be removed by unrelated nav changes")
    }

    // MARK: - set() — re-anchoring and bootstrap

    func test_set_noFalseCancel_whenCoordinatorReplacesStack() {
        let pushing = PushingCoordinator(navigationController: nav)
        parent.addChildAndStart(pushing)

        pushing.set([UIViewController()])  // coordinator's own set() — must re-anchor, not cancel

        XCTAssertEqual(parent.childCoordinators.count, 1,
                       "Coordinator replacing its own stack must not be removed")
    }

    func test_set_reanchors_popNewVCTriggersCancelAfterSet() {
        let pushing = PushingCoordinator(navigationController: nav)
        parent.addChildAndStart(pushing)

        let d = UIViewController()
        pushing.set([d])
        XCTAssertEqual(parent.childCoordinators.count, 1)

        nav.viewControllers = nav.viewControllers.filter { $0 !== d }

        XCTAssertTrue(parent.childCoordinators.isEmpty,
                      "Pop of re-anchored VC must trigger cancel")
    }

    func test_set_bootstrapsTracking_whenNotPreviouslyTracked() {
        // Coordinator added via addChild (not addChildAndStart) — no tracking yet.
        parent.addChild(child)

        let d = UIViewController()
        child.set([d])       // bootstraps tracking on d
        nav.viewControllers = []  // simulate external removal of d

        XCTAssertTrue(parent.childCoordinators.isEmpty,
                      "set() on untracked coordinator should bootstrap tracking")
    }

    func test_set_emptyArray_cancels_whenTracked() {
        let pushing = PushingCoordinator(navigationController: nav)
        parent.addChildAndStart(pushing)

        pushing.set([])  // empty set — treated as flow abandonment

        XCTAssertTrue(parent.childCoordinators.isEmpty,
                      "set([]) should be treated as flow abandonment")
    }

    // MARK: - finish() and cancel() are independent override points

    func test_finish_doesNotCallCancelOverride() {
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
