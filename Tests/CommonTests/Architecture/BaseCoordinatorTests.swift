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

    /// Pushes a VC and reports its own cancellation — the flag outlives the
    /// coordinator, so tests can observe cancels without holding it alive.
    private final class CancelObservingCoordinator: BaseCoordinator {
        let pushedVC = UIViewController()
        private let onCancelled: () -> Void

        init(navigationController: UINavigationController, onCancelled: @escaping () -> Void) {
            self.onCancelled = onCancelled
            super.init(navigationController: navigationController)
        }

        override func start() {
            navigationController.viewControllers =
                navigationController.viewControllers + [pushedVC]
        }

        override func cancel() {
            onCancelled()
            super.cancel()
        }
    }

    /// Records UIKit's containment callback so the harness can prove which
    /// removal paths deliver it.
    private final class ContainmentProbeViewController: UIViewController {
        var leftParentCount = 0
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            if parent == nil { leftParentCount += 1 }
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

    func test_finish_isIdempotent_siblingSurvivesDoubleFinish() {
        // With a single child, "removed once" and "removed twice" are
        // indistinguishable (removing from an empty array is a no-op) — the
        // sibling is what a removeAll-style over-removal would take out.
        let sibling = StubCoordinator(navigationController: nav)
        parent.addChild(child)
        parent.addChild(sibling)

        child.finish()
        child.finish()

        XCTAssertEqual(parent.childCoordinators.count, 1)
        XCTAssertTrue(parent.childCoordinators.first === sibling)
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
        // Re-adding the child between calls is what discriminates the guard:
        // a second cancel() must short-circuit on isFinished and leave the
        // re-added child in place; without the guard it would remove it again.
        parent.addChild(child)
        child.cancel()
        XCTAssertTrue(parent.childCoordinators.isEmpty)

        parent.addChild(child)
        child.cancel()
        XCTAssertEqual(parent.childCoordinators.count, 1)
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

    // MARK: - Navigation stack mechanics (push / pop / set)

    func test_push_appendsToNavigationStack_inOrder() {
        let a = UIViewController()
        let b = UIViewController()
        parent.set(a, animated: false)

        parent.push(b, animated: false)

        XCTAssertEqual(nav.viewControllers, [a, b])
        XCTAssertTrue(nav.topViewController === b)
    }

    func test_pop_removesOnlyTopViewController() {
        let a = UIViewController()
        let b = UIViewController()
        let c = UIViewController()
        parent.set([a, b, c], animated: false)

        parent.pop(.back, animated: false)

        XCTAssertEqual(nav.viewControllers, [a, b], "pop(.back) must remove exactly one level")
    }

    func test_popTo_unwindsToExactTarget() {
        let a = UIViewController()
        let b = UIViewController()
        let c = UIViewController()
        let d = UIViewController()
        parent.set([a, b, c, d], animated: false)

        parent.pop(.to(viewController: b), animated: false)

        XCTAssertEqual(nav.viewControllers, [a, b], "pop(.to:) must unwind to the given VC, not root or one level")
    }

    func test_popToRoot_leavesOnlyRoot() {
        let a = UIViewController()
        let b = UIViewController()
        let c = UIViewController()
        parent.set([a, b, c], animated: false)

        parent.pop(.toRoot, animated: false)

        XCTAssertEqual(nav.viewControllers, [a])
    }

    func test_set_replacesEntireStack_inOrder() {
        parent.set([UIViewController(), UIViewController()], animated: false)
        let root = UIViewController()

        parent.set([root], animated: false)

        XCTAssertEqual(nav.viewControllers, [root], "set must replace, not append")
    }

    // MARK: - Stack-removal tracking (gesture-driven cleanup)

    // Tracking rides UIKit's view-controller containment callback. The probes
    // above measure why: `didMove(toParent: nil)` is delivered for real pops,
    // multi-pops, AND stack assignment, whereas KVO on `\.viewControllers`
    // (the previous mechanism) fires only for assignment — so back-button,
    // swipe-back, and popViewController removals went unreported, and no unit
    // test could see it because they all simulate pops by assigning the stack.

    /// Also codifies that removal-driven cancel runs on the same runloop tick as
    /// the nav-stack mutation (no expectation/await below): the containment
    /// callback is delivered synchronously, so deferring cleanup onto a Task
    /// would break this test.
    func test_stackRemoval_popRemovesCoordinatorFromParent() {
        let pushing = PushingCoordinator(navigationController: nav)
        parent.addChildAndStart(pushing)
        XCTAssertEqual(parent.childCoordinators.count, 1)

        nav.viewControllers = Array(nav.viewControllers.dropLast())

        XCTAssertTrue(parent.childCoordinators.isEmpty,
                      "stack removal should have triggered cancel() and removed coordinator from parent")
    }

    func test_stackRemoval_popDoesNotFireOnPerformed() {
        var called = false
        let pushing = PushingCoordinator(navigationController: nav) { _ in called = true }
        parent.addChildAndStart(pushing)

        nav.viewControllers = Array(nav.viewControllers.dropLast())

        XCTAssertFalse(called, "cancel() must not fire onPerformed")
    }

    func test_stackRemoval_finishBeforePopSuppressesDoubleCleanup() {
        var callCount = 0
        let pushing = PushingCoordinator(navigationController: nav) { _ in callCount += 1 }
        parent.addChildAndStart(pushing)

        pushing.finish()                                              // marks isFinished = true, stops tracking
        nav.viewControllers = Array(nav.viewControllers.dropLast())  // removal reported, but tracking is already torn down

        XCTAssertEqual(callCount, 1)
        XCTAssertTrue(parent.childCoordinators.isEmpty)
    }

    /// A tracked-then-finished coordinator must deallocate: a strong reference
    /// from the tracked view controller's registration (or a registration
    /// outliving termination) would leak every child flow.
    func test_finishedCoordinator_deallocates() {
        weak var weakCoordinator: BaseCoordinator?
        autoreleasepool {
            let pushing = PushingCoordinator(navigationController: nav)
            parent.addChildAndStart(pushing)
            weakCoordinator = pushing
            pushing.finish()
        }
        XCTAssertNil(weakCoordinator, "finished coordinator must not be retained by its removal registration")
    }

    func test_stackRemoval_noTrackingWhenCoordinatorDoesNotPush() {
        parent.addChildAndStart(child)  // StubCoordinator.start() does not push any VC

        // Unrelated nav mutations must not affect an untracked coordinator.
        nav.viewControllers = [UIViewController()]
        nav.viewControllers = []

        XCTAssertEqual(parent.childCoordinators.count, 1,
                       "Non-pushing coordinator must not be removed by unrelated nav changes")
    }

    // MARK: - Containment probe (which removal paths does UIKit report?)

    func test_probe_realPopDeliversContainmentCallback() {
        nav.viewControllers = [UIViewController()] // root: popping a lone root is a no-op
        let probe = ContainmentProbeViewController()
        nav.pushViewController(probe, animated: false)
        XCTAssertEqual(probe.leftParentCount, 0)

        nav.popViewController(animated: false)

        XCTAssertEqual(probe.leftParentCount, 1, "PROBE: real pop must deliver didMove(toParent: nil)")
    }

    func test_probe_stackAssignmentDeliversContainmentCallback() {
        let root = UIViewController()
        nav.viewControllers = [root]
        let probe = ContainmentProbeViewController()
        nav.viewControllers = [root, probe]

        nav.viewControllers = [root]

        XCTAssertEqual(probe.leftParentCount, 1, "PROBE: stack assignment must deliver didMove(toParent: nil)")
    }

    func test_probe_popToViewControllerDeliversContainmentCallbackForEachRemoved() {
        let root = UIViewController()
        nav.viewControllers = [root]
        let first = ContainmentProbeViewController()
        let second = ContainmentProbeViewController()
        nav.pushViewController(first, animated: false)
        nav.pushViewController(second, animated: false)

        nav.popToViewController(root, animated: false)

        XCTAssertEqual(first.leftParentCount, 1, "PROBE: multi-pop must report every removed VC")
        XCTAssertEqual(second.leftParentCount, 1, "PROBE: multi-pop must report every removed VC")
    }

    // MARK: - Real pop cancellation (the production path)

    func test_realPop_cancelsTrackedCoordinator() {
        nav.viewControllers = [UIViewController()] // seed a root so the pop is legal
        let pushing = PushingCoordinator(navigationController: nav)
        parent.addChildAndStart(pushing)
        XCTAssertEqual(parent.childCoordinators.count, 1)
        XCTAssertEqual(nav.viewControllers.count, 2, "precondition: tracked VC sits above a root")

        nav.popViewController(animated: false)

        XCTAssertTrue(parent.childCoordinators.isEmpty,
                      "a real pop (back button / popViewController) must cancel the child coordinator")
    }

    func test_realPop_doesNotFireOnPerformed() {
        nav.viewControllers = [UIViewController()]
        var called = false
        let pushing = PushingCoordinator(navigationController: nav) { _ in called = true }
        parent.addChildAndStart(pushing)

        nav.popViewController(animated: false)

        XCTAssertFalse(called, "pop-driven cancel() must not fire onPerformed")
    }

    func test_popToViewController_cancelsEveryStackedCoordinator() {
        let root = UIViewController()
        nav.viewControllers = [root]

        let first = PushingCoordinator(navigationController: nav)
        parent.addChildAndStart(first)
        let second = PushingCoordinator(navigationController: nav)
        first.addChildAndStart(second)
        XCTAssertEqual(parent.childCoordinators.count, 1)
        XCTAssertEqual(first.childCoordinators.count, 1)

        nav.popToViewController(root, animated: false)

        XCTAssertTrue(first.childCoordinators.isEmpty, "the deeper coordinator must cancel")
        XCTAssertTrue(parent.childCoordinators.isEmpty, "the shallower coordinator must cancel")
    }

    // MARK: - Cancellation cascade

    /// Descendants are retained only by their parent's `childCoordinators`, so a
    /// parent that cancels first would deallocate them before their own removal
    /// is reported — their `cancel()` would silently never run. Abandoning a flow
    /// must abandon the whole subtree.
    func test_cancel_cascadesToChildCoordinators() {
        var deepCancelled = false
        let first = PushingCoordinator(navigationController: nav)
        parent.addChildAndStart(first)
        first.addChildAndStart(
            CancelObservingCoordinator(navigationController: nav) { deepCancelled = true }
        )

        first.cancel()

        XCTAssertTrue(deepCancelled,
                      "cancelling a coordinator must cancel its children — they belong to the same abandoned flow")
    }

    /// Production shape of the multi-pop cascade: only the coordinator tree holds
    /// the descendants (no test-local strong references propping them up).
    func test_popToViewController_cancelsEveryCoordinator_whenOnlyTheTreeRetainsThem() {
        let root = UIViewController()
        nav.viewControllers = [root]
        var cancels = 0

        let first = CancelObservingCoordinator(navigationController: nav) { cancels += 1 }
        parent.addChildAndStart(first)
        first.addChildAndStart(
            CancelObservingCoordinator(navigationController: nav) { cancels += 1 }
        )

        nav.popToViewController(root, animated: false)

        XCTAssertEqual(cancels, 2, "every coordinator in the popped subtree must observe its own cancellation")
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

    // MARK: - set() by a descendant re-roots, it does not abandon the ancestors

    func test_set_descendantReroot_keepsAncestorAndCallerActive() {
        var parentPerformed = false
        let root = StubCoordinator(navigationController: nav, onPerformed: { _ in parentPerformed = true })
        root.set([UIViewController()])            // the parent tracks its own root screen
        let flow = StubCoordinator(navigationController: nav)
        root.addChildAndStart(flow)

        flow.set([UIViewController()])            // e.g. login → set(home) from the child

        XCTAssertEqual(root.childCoordinators.count, 1,
                       "the re-root must not cancel the child through its parent's cascade")
        root.finish()
        XCTAssertTrue(parentPerformed, "the parent must still be active, so finish() fires onPerformed")
    }

    func test_set_ancestorTakesStackBackAfterDescendantReroot_cancelsOnlyTheDescendant() {
        var parentPerformed = false
        let root = StubCoordinator(navigationController: nav, onPerformed: { _ in parentPerformed = true })
        root.set([UIViewController()])
        let flow = StubCoordinator(navigationController: nav)
        root.addChildAndStart(flow)
        flow.set([UIViewController()])

        root.set([UIViewController()])            // the child's root leaves the stack

        XCTAssertTrue(root.childCoordinators.isEmpty, "the child tracks the root it set, so its removal cancels it")
        root.finish()
        XCTAssertTrue(parentPerformed, "the parent re-rooted its own flow and stays active")
    }

    func test_set_descendantKeepsAncestorScreen_ancestorStillTracksIt() {
        let rootScreen = UIViewController()
        let root = StubCoordinator(navigationController: nav)
        root.set([rootScreen])
        let flow = StubCoordinator(navigationController: nav)
        root.addChildAndStart(flow)
        let flowScreen = UIViewController()
        flow.set([flowScreen, rootScreen])        // re-roots, but the parent's screen stays in the stack

        nav.viewControllers = [flowScreen]        // only the parent's screen leaves

        XCTAssertTrue(root.childCoordinators.isEmpty,
                      "the parent kept tracking its screen, so its removal cancels the parent and cascades to the child")
    }

    func test_set_emptyArrayByDescendant_stillCancelsTheTrackingAncestor() {
        var parentPerformed = false
        let root = StubCoordinator(navigationController: nav, onPerformed: { _ in parentPerformed = true })
        root.set([UIViewController()])
        let flow = StubCoordinator(navigationController: nav)
        root.addChildAndStart(flow)

        flow.set([])                              // flow abandonment, not a re-root

        XCTAssertTrue(root.childCoordinators.isEmpty)
        root.finish()
        XCTAssertFalse(parentPerformed, "the parent's screen was abandoned too, so it is cancelled and finish() is a no-op")
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
