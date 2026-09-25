//
//  AlertPresentationHostedTests.swift
//

import UIKit
import XCTest
import Common

/// Alert taps and presentation. Hosted: control actions only dispatch in a running app, and
/// presenting goes through the key window of a foreground-active scene.
@MainActor
final class AlertPresentationHostedTests: XCTestCase {

    private final class AlertingCoordinator: BaseCoordinator {
        var dismissalRequests = 0
        override func onDismissRequested() { dismissalRequests += 1 }
    }

    override func setUp() async throws {
        try await super.setUp()
        UIView.setAnimationsEnabled(false)
    }

    override func tearDown() async throws {
        if let alert = UIApplication.shared.topMostViewController as? CustomAlertViewController {
            await withCheckedContinuation { continuation in alert.dismiss(animated: false) { continuation.resume() } }
        }
        UIView.setAnimationsEnabled(true)
        try await super.tearDown()
    }

    // MARK: - A presented alert does not keep its coordinator alive

    func test_coordinator_isReleased_whileItsAlertIsPresented() {
        weak var weakCoordinator: AlertingCoordinator?
        autoreleasepool {
            let coordinator = AlertingCoordinator(navigationController: UINavigationController())
            coordinator.onPresentAlertRequested(viewModel: payload())
            weakCoordinator = coordinator
        }

        XCTAssertTrue(UIApplication.shared.topMostViewController is CustomAlertViewController, "precondition: the alert is on screen")
        XCTAssertNil(weakCoordinator, "the presented alert must not keep its coordinator alive")
    }

    func test_backgroundTap_reachesTheLiveCoordinator() throws {
        let coordinator = AlertingCoordinator(navigationController: UINavigationController())
        coordinator.onPresentAlertRequested(viewModel: payload())
        let alert = try XCTUnwrap(UIApplication.shared.topMostViewController as? CustomAlertViewController)

        try XCTUnwrap(buttons(in: alert.view).first, "the dimming background button").sendActions(for: .touchUpInside)

        XCTAssertEqual(coordinator.dismissalRequests, 1)
    }

    // MARK: - Handlers still fire

    func test_customAlertController_backgroundTap_requestsDismissal() throws {
        var dismissalRequests = 0
        let controller = CustomAlertViewController(contentView: UIView(), onDismissRequested: { dismissalRequests += 1 })
        controller.loadViewIfNeeded()

        try XCTUnwrap(buttons(in: controller.view).first, "the dimming background button").sendActions(for: .touchUpInside)

        XCTAssertEqual(dismissalRequests, 1)
    }

    func test_alertView_actionAndCancelButtons_invokeTheirHandlers() {
        var actions = 0
        var cancels = 0
        let view = AlertView(viewModel: payload(onAction: { actions += 1 }, onCancel: { cancels += 1 }))
        let found = buttons(in: view)
        XCTAssertEqual(found.count, 2, "precondition: an action and a cancel button")

        found.forEach { $0.sendActions(for: .touchUpInside) }

        XCTAssertEqual(actions, 1)
        XCTAssertEqual(cancels, 1)
    }

    // MARK: - Helpers

    private func payload(onAction: CompletionHandler = {}, onCancel: CompletionHandler = nil) -> AlertViewModelPayload {
        AlertViewModelPayload(title: "Title", attributedMessage: .init(string: "Message"),
                              onActionButtonPressedHandler: onAction, onCancelButtonPressedHandler: onCancel)
    }

    private func buttons(in view: UIView) -> [UIButton] {
        view.subviews.flatMap { subview -> [UIButton] in
            if let button = subview as? UIButton { return [button] }
            return buttons(in: subview)
        }
    }
}
