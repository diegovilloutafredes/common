//
//  SnackbarHostedTests.swift
//

import UIKit
import XCTest
import Common

/// Snackbar taps. Hosted: control actions only dispatch in a running app, and the snackbar is added to the key window
/// of a foreground-active scene.
@MainActor
final class SnackbarHostedTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        UIView.setAnimationsEnabled(false)
    }

    override func tearDown() async throws {
        UIView.setAnimationsEnabled(true)
        try await super.tearDown()
    }

    private func buttons(titled title: String, in view: UIView) -> [UIButton] {
        view.subviews.flatMap { subview -> [UIButton] in
            if let button = subview as? UIButton, button.title(for: .normal) == title { return [button] }
            return buttons(titled: title, in: subview)
        }
    }

    /// The defect: dismissal had no re-entry guard, so a double tap on the action ran onAction twice and dismissed twice.
    func test_doubleTapOnAction_firesOnActionAndOnDismissOnce() throws {
        var actions = 0, dismissals = 0
        let dismissed = expectation(description: "dismissed")
        dismissed.assertForOverFulfill = false  // a second dismissal is reported by the count below
        Snackbar.show(.init(
            message: "Saved",
            actionTitle: "Undo",
            onAction: { actions += 1 },
            onDismiss: { dismissals += 1; dismissed.fulfill() }
        ))
        let window = try XCTUnwrap(UIView().keyWindow)
        let action = try XCTUnwrap(buttons(titled: "Undo", in: window).first, "the snackbar's action button")

        action.sendActions(for: .touchUpInside)
        action.sendActions(for: .touchUpInside)
        wait(for: [dismissed], timeout: 5)
        // A second dismissal, if any, lands on the next run-loop passes.
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

        XCTAssertEqual(actions, 1)
        XCTAssertEqual(dismissals, 1)
    }
}
