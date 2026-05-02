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
}
