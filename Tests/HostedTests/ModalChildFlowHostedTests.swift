//
//  ModalChildFlowHostedTests.swift
//

import UIKit
import XCTest
import Common

/// `presentChild(_:animated:)`: a child flow in its own navigation controller, presented as a sheet. Hosted: the
/// sheet is presented from the host app's top-most controller, which each parent here takes as its anchor.
@MainActor
final class ModalChildFlowHostedTests: XCTestCase {

    private final class AnchoredParent: BaseCoordinator {
        weak var anchor: UIViewController?
        override var presentationAnchor: UIViewController? { anchor }
    }

    /// Shows one screen in its own navigation controller.
    private final class SheetChild: BaseCoordinator {
        var finishesWhileStarting = false
        private(set) var startCount = 0

        override func start() {
            startCount += 1
            set(UIViewController())
            if finishesWhileStarting { finish() }
        }
    }

    /// Declares the conformance `BaseCoordinator` deliberately doesn't have; it must keep compiling.
    private final class SelfDelegatingCoordinator: BaseCoordinator, UIAdaptivePresentationControllerDelegate {
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {}
    }

    override func setUp() async throws {
        try await super.setUp()
        UIView.setAnimationsEnabled(false)
    }

    override func tearDown() async throws {
        UIView.setAnimationsEnabled(false)
        await dismissEverything()
        UIView.setAnimationsEnabled(true)
        try await super.tearDown()
    }

    // MARK: - Presenting

    func test_presentChild_addsStartsAndPresentsTheChild() async throws {
        let parent = try makeParent()
        let child = SheetChild(navigationController: UINavigationController())

        parent.presentChild(child, animated: false)
        await waitUntilPresented(child)

        XCTAssertTrue(parent.childCoordinators.contains { $0 === child })
        XCTAssertEqual(child.startCount, 1)
    }

    func test_childFinishingWhileStarting_isNeverPresented() async throws {
        let parent = try makeParent()
        var performedCount = 0
        let child = SheetChild(navigationController: UINavigationController()) { _ in performedCount += 1 }
        child.finishesWhileStarting = true

        parent.presentChild(child, animated: false)
        for _ in 0..<5 { await Task.yield() }

        XCTAssertNil(child.navigationController.presentingViewController)
        XCTAssertEqual(performedCount, 1)
        XCTAssertFalse(parent.childCoordinators.contains { $0 === child })
    }

    // MARK: - Interactive dismissal

    func test_interactiveDismissal_cancelsTheChildWithoutOnPerformed() async throws {
        let parent = try makeParent()
        var performedCount = 0
        let child = SheetChild(navigationController: UINavigationController()) { _ in performedCount += 1 }
        parent.presentChild(child, animated: false)
        await waitUntilPresented(child)
        let presentationController = try XCTUnwrap(child.navigationController.presentationController)
        let delegate = try XCTUnwrap(presentationController.delegate, "presentChild set a presentation controller delegate")

        delegate.presentationControllerDidDismiss?(presentationController)

        XCTAssertTrue(child.isFinished)
        XCTAssertFalse(parent.childCoordinators.contains { $0 === child })
        XCTAssertEqual(performedCount, 0)
    }

    // MARK: - Ending the flow

    func test_finish_dismissesTheSheet_thenRunsOnPerformedOnce() async throws {
        let parent = try makeParent()
        var performedCount = 0
        var sheetWasPresentedInOnPerformed: Bool?
        let performed = expectation(description: "onPerformed runs")
        let child = SheetChild(navigationController: UINavigationController()) { coordinator in
            performedCount += 1
            sheetWasPresentedInOnPerformed = (coordinator as? BaseCoordinator)?.navigationController.presentingViewController != nil
            performed.fulfill()
        }
        parent.presentChild(child, animated: false)
        await waitUntilPresented(child)

        child.finish()
        await fulfillment(of: [performed], timeout: transitionTimeout)
        for _ in 0..<5 { await Task.yield() }

        XCTAssertEqual(performedCount, 1)
        XCTAssertEqual(sheetWasPresentedInOnPerformed, false, "onPerformed runs once the sheet is gone")
        XCTAssertFalse(parent.childCoordinators.contains { $0 === child })
    }

    func test_parent_presentsItsNextScreenFromOnPerformed() async throws {
        let parent = try makeParent()
        let next = UIViewController()
        let child = SheetChild(navigationController: UINavigationController()) { [weak parent] _ in
            parent?.present(.overCurrent, viewController: next, animated: false)
        }
        parent.presentChild(child, animated: false)
        await waitUntilPresented(child)

        child.finish()

        await waitUntil("the next screen is presented") { next.presentingViewController != nil }
        withExtendedLifetime(parent) {}   // an app keeps its parent coordinator alive; a test local may end early
    }

    func test_childCancel_dismissesTheSheet() async throws {
        let parent = try makeParent()
        let child = SheetChild(navigationController: UINavigationController())
        parent.presentChild(child, animated: false)
        await waitUntilPresented(child)

        child.cancel()

        await waitUntil("the sheet is dismissed") { child.navigationController.presentingViewController == nil }
        withExtendedLifetime(parent) {}
    }

    func test_parentCancel_cascadesAndDismissesTheSheet() async throws {
        let parent = try makeParent()
        let child = SheetChild(navigationController: UINavigationController())
        parent.presentChild(child, animated: false)
        await waitUntilPresented(child)

        parent.cancel()

        XCTAssertTrue(child.isFinished)
        await waitUntil("the sheet is dismissed") { child.navigationController.presentingViewController == nil }
    }

    func test_finishWhileTheSheetIsStillBeingPresented_dismissesItOnceThePresentationCompletes() async throws {
        UIView.setAnimationsEnabled(true)
        let parent = try makeParent()
        let performed = expectation(description: "onPerformed runs")
        var sheetWasPresentedInOnPerformed: Bool?
        let child = SheetChild(navigationController: UINavigationController()) { coordinator in
            sheetWasPresentedInOnPerformed = (coordinator as? BaseCoordinator)?.navigationController.presentingViewController != nil
            performed.fulfill()
        }
        parent.presentChild(child, animated: true)
        XCTAssertTrue(child.navigationController.isBeingPresented, "precondition: the presentation is still running")

        child.finish()

        await fulfillment(of: [performed], timeout: transitionTimeout)
        XCTAssertEqual(sheetWasPresentedInOnPerformed, false)
        withExtendedLifetime(parent) {}
    }

    func test_parentDismissInOnPerformed_dismissesNothingElse() async throws {
        let host = try XCTUnwrap(UIApplication.shared.topMostViewController)
        let screen = UIViewController()
        await transition("the parent's screen is presented") { host.present(screen, animated: false, completion: $0) }
        let parent = AnchoredParent(navigationController: UINavigationController())
        parent.anchor = screen
        let performed = expectation(description: "onPerformed runs")
        let child = SheetChild(navigationController: UINavigationController()) { [weak parent] _ in
            parent?.dismiss(animated: false)   // what the manual wiring did
            performed.fulfill()
        }
        parent.presentChild(child, animated: false)
        await waitUntilPresented(child)

        child.finish()
        await fulfillment(of: [performed], timeout: transitionTimeout)
        for _ in 0..<5 { await Task.yield() }

        XCTAssertNotNil(screen.presentingViewController, "the parent's own screen stays presented")
        XCTAssertNil(screen.presentedViewController)
        withExtendedLifetime(parent) {}   // the parent's dismiss() above must have run for this test to mean anything
    }

    /// The sheet goes with anything presented over it, here a nested child's sheet, and the nested child is
    /// cancelled.
    func test_finish_dismissesTheSheetWithANestedChildsSheet() async throws {
        let parent = try makeParent()
        let performed = expectation(description: "onPerformed runs")
        var sheetsPresentedInOnPerformed: [Bool] = []
        let nested = SheetChild(navigationController: UINavigationController())
        let child = SheetChild(navigationController: UINavigationController()) { coordinator in
            let outer = (coordinator as? BaseCoordinator)?.navigationController
            sheetsPresentedInOnPerformed = [outer?.presentingViewController != nil, nested.navigationController.presentingViewController != nil]
            performed.fulfill()
        }
        parent.presentChild(child, animated: false)
        await waitUntilPresented(child)
        child.presentChild(nested, animated: false)
        await waitUntilPresented(nested)

        child.finish()
        await fulfillment(of: [performed], timeout: transitionTimeout)

        XCTAssertTrue(nested.isFinished)
        XCTAssertEqual(sheetsPresentedInOnPerformed, [false, false])
        withExtendedLifetime(parent) {}
    }

    func test_subclassDeclaringThePresentationControllerDelegate_compiles() {
        XCTAssertNotNil(SelfDelegatingCoordinator(navigationController: UINavigationController()))
    }

    // MARK: - Helpers

    private func makeParent() throws -> AnchoredParent {
        let parent = AnchoredParent(navigationController: UINavigationController())
        parent.anchor = try XCTUnwrap(UIApplication.shared.topMostViewController, "the host app has a key window")
        return parent
    }

    private func waitUntilPresented(_ child: BaseCoordinator) async {
        let navigation = child.navigationController
        await waitUntil("the sheet is presented") {
            navigation.presentingViewController != nil && !navigation.isBeingPresented && navigation.viewIfLoaded?.window != nil
        }
    }

    private func waitUntil(_ description: String, _ condition: @escaping () -> Bool) async {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in condition() }, object: nil)
        expectation.expectationDescription = description
        await fulfillment(of: [expectation], timeout: transitionTimeout)
    }

    /// Runs `start`, which calls its argument when a transition completes, and waits for that, failing at the timeout
    /// instead of hanging.
    private func transition(_ description: String, _ start: (@escaping () -> Void) -> Void) async {
        let completed = expectation(description: description)
        start { completed.fulfill() }
        await fulfillment(of: [completed], timeout: transitionTimeout)
    }

    /// Dismisses everything presented over the host's root controller.
    private func dismissEverything() async {
        var root = UIApplication.shared.topMostViewController
        while let presenting = root?.presentingViewController { root = presenting }
        guard let root, root.presentedViewController != nil else { return }
        await transition("the host's presentations are dismissed") { root.dismiss(animated: false, completion: $0) }
    }
}
