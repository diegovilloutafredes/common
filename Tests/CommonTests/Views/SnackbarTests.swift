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

    // MARK: - Dismissal contract (S2)

    func test_show_withoutHostWindow_deliversOnDismissOnce() {
        Snackbar.hostWindow = { nil }
        var dismissed = 0

        Snackbar.show(.init(message: "orphan", onDismiss: { dismissed += 1 }))
        pumpRunLoop()

        XCTAssertEqual(dismissed, 1, "a snackbar that cannot show must still deliver onDismiss — callers awaiting dismissal must not stall")
        XCTAssertTrue(snackbars().isEmpty, "no snackbar may be installed without a host window")
    }

    // MARK: - Scroll-immune auto-dismiss (S3)

    func test_autoDismiss_firesDuringScrollTracking() {
        // Hostless bundle: UIKit hasn't put the tracking mode in the common set
        // (UIApplicationMain does that in a real app) — replicate it so the test
        // drives the production run-loop configuration.
        CFRunLoopAddCommonMode(CFRunLoopGetMain(), CFRunLoopMode(RunLoop.Mode.tracking.rawValue as CFString))
        var dismissed = 0
        Snackbar.show(.init(message: "scrolling", duration: .custom(0.05), onDismiss: { dismissed += 1 }))

        // Drive ONLY the tracking run-loop mode — what UIKit runs while the
        // user drags a scroll view. A timer scheduled in the default mode never
        // fires here; one registered in .common does.
        let deadline = Date(timeIntervalSinceNow: 2)
        while dismissed == 0 && Date() < deadline {
            RunLoop.main.run(mode: .tracking, before: Date(timeIntervalSinceNow: 0.05))
        }

        XCTAssertEqual(dismissed, 1, "the auto-dismiss timer must keep counting during scroll tracking (.common mode)")
    }

    // MARK: - Touch pass-through (S4)

    func test_touches_passThroughOutsideCard() {
        Snackbar.show(.init(message: "hit test"))
        guard let snackbar = snackbars().first else { return XCTFail("snackbar must be installed") }
        window.layoutIfNeeded()

        let sideStrip = CGPoint(x: 4, y: snackbar.bounds.midY)
        XCTAssertFalse(
            snackbar.point(inside: sideStrip, with: nil),
            "touches on the transparent strip beside the card must fall through to the UI beneath"
        )
    }

    func test_cardAndActionButton_remainInteractive() {
        var actioned = 0
        Snackbar.show(.init(message: "tap me", actionTitle: "Do", onAction: { actioned += 1 }))
        guard let snackbar = snackbars().first else { return XCTFail("snackbar must be installed") }
        window.layoutIfNeeded()

        XCTAssertTrue(
            snackbar.point(inside: CGPoint(x: snackbar.bounds.midX, y: snackbar.bounds.midY), with: nil),
            "the card itself must keep receiving touches"
        )

        guard let button = buttons(in: snackbar).first else { return XCTFail("action button must exist") }
        tap(button)
        pumpRunLoop()

        XCTAssertEqual(actioned, 1, "the action button must stay tappable after the hit-test carve-out")
        XCTAssertTrue(snackbars().isEmpty, "the action tap must still dismiss the snackbar")
    }

    /// `sendActions` routes through `UIApplication.shared.sendAction`, which is
    /// inert in this hostless test bundle — invoke the registered target-action
    /// pairs directly instead.
    private func tap(_ control: UIControl) {
        control.allTargets.forEach { target in
            control.actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }

    private func buttons(in view: UIView) -> [UIButton] {
        var found = [UIButton]()
        if let button = view as? UIButton { found.append(button) }
        view.subviews.forEach { found.append(contentsOf: buttons(in: $0)) }
        return found
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
