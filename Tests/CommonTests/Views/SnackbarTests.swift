//
//  SnackbarTests.swift
//

import UIKit
import XCTest
@testable import Common

@MainActor
final class SnackbarTests: XCTestCase {

    private var window: UIWindow!
    private var originalHostWindow: (() -> UIWindow?)!

    override func setUp() async throws {
        window = UIWindow(frame: .init(x: 0, y: 0, width: 320, height: 640))
        window.makeKeyAndVisible()
        originalHostWindow = Snackbar.hostWindow
        Snackbar.hostWindow = { [weak window] in window }
        // Animation completions run synchronously with animations disabled —
        // dismissal (spring + fade) becomes deterministic in the harness.
        UIView.setAnimationsEnabled(false)
    }

    override func tearDown() async throws {
        Snackbar.current?.dismiss()
        UIView.setAnimationsEnabled(true)
        Snackbar.hostWindow = originalHostWindow
        window.isHidden = true
        window = nil
    }

    private func snackbars() -> [SnackbarView] {
        window.subviews.compactMap { $0 as? SnackbarView }
    }

    /// Dismissal completions are delivered on a later run-loop pass even with
    /// animations disabled — pump briefly before asserting on post-dismiss state.
    private func pumpRunLoop(_ interval: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: interval))
    }

    // MARK: - Single presentation (S1)

    func test_show_addsSingleSnackbarToHostWindow() {
        Snackbar.show(.init(message: "one"))

        XCTAssertEqual(snackbars().count, 1)
        XCTAssertTrue(Snackbar.current === snackbars().first)
    }

    func test_secondShow_dismissesFirst() {
        var firstDismissed = 0
        Snackbar.show(.init(message: "first", onDismiss: { firstDismissed += 1 }))

        Snackbar.show(.init(message: "second"))
        pumpRunLoop()

        XCTAssertEqual(firstDismissed, 1, "showing a snackbar must dismiss the one already on screen — they must not stack")
        XCTAssertEqual(snackbars().count, 1, "at most one snackbar may be on screen")
        XCTAssertTrue(Snackbar.current === snackbars().first)
    }

    func test_showAfterDismiss_presentsFreshSnackbar() {
        Snackbar.show(.init(message: "one"))
        Snackbar.current?.dismiss()
        // Dismissal completion lands on a later run-loop pass — poll it out.
        let deadline = Date(timeIntervalSinceNow: 2)
        while !snackbars().isEmpty && Date() < deadline { pumpRunLoop() }
        XCTAssertTrue(snackbars().isEmpty, "dismiss must remove the snackbar from the window")

        Snackbar.show(.init(message: "two"))

        XCTAssertEqual(snackbars().count, 1, "a dismissed snackbar must not break the next show")
        XCTAssertTrue(Snackbar.current === snackbars().first)
    }
}
