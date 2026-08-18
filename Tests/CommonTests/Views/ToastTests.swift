//
//  ToastTests.swift
//

import UIKit
import XCTest
@testable import Common

@MainActor
final class ToastTests: XCTestCase {

    private var window: UIWindow!
    private var host: UIView!
    private var originalHostView: (() -> UIView?)!

    override func setUp() async throws {
        window = UIWindow(frame: .init(x: 0, y: 0, width: 320, height: 640))
        window.makeKeyAndVisible()
        host = UIView(frame: window.bounds)
        window.addSubview(host)
        originalHostView = Toast.hostView
        Toast.hostView = { [weak host] in host }
        // Animation completions run synchronously with animations disabled —
        // fade-in/fade-out become deterministic in the harness.
        UIView.setAnimationsEnabled(false)
    }

    override func tearDown() async throws {
        Toast.dismissCurrent()
        UIView.setAnimationsEnabled(true)
        Toast.hostView = originalHostView
        window.isHidden = true
        window = nil
        host = nil
    }

    /// The presented toast containers currently on the host — a toast is a
    /// stack wrapping a `PillUILabel`.
    private func toasts() -> [UIStackView] {
        host.subviews.compactMap { $0 as? UIStackView }
    }

    private func labelTexts(in view: UIView) -> [String] {
        var texts = [String]()
        if let label = view as? UILabel, let text = label.text { texts.append(text) }
        view.subviews.forEach { texts.append(contentsOf: labelTexts(in: $0)) }
        return texts
    }

    // MARK: - Completion contract

    func test_present_withoutHostView_deliversCompletionOnce() async {
        Toast.hostView = { nil }
        let completed = expectation(description: "completion delivered with no host view")
        var completions = 0

        Toast.present(with: "orphan") { completions += 1; completed.fulfill() }

        await fulfillment(of: [completed], timeout: 3)
        XCTAssertEqual(completions, 1, "the no-host path must deliver the completion exactly once")
        XCTAssertTrue(toasts().isEmpty, "no toast may be installed when there is no host view")
    }

    func test_present_completesOnceAfterNaturalDismissal() async {
        let completed = expectation(description: "completion delivered after dismissal")
        var completions = 0

        Toast.present(with: "hello", duration: .short) { completions += 1; completed.fulfill() }
        XCTAssertEqual(toasts().count, 1, "the toast must be on the host while showing")

        // .short holds for 1s; the ceiling only matters on broken runs.
        await fulfillment(of: [completed], timeout: 10)
        XCTAssertEqual(completions, 1)
        XCTAssertTrue(toasts().isEmpty, "the toast must leave the hierarchy before its completion fires")
    }

    // MARK: - Single presentation

    func test_secondPresent_replacesFirst() {
        var firstCompletions = 0
        Toast.present(with: "first") { firstCompletions += 1 }

        Toast.present(with: "second")

        XCTAssertEqual(firstCompletions, 1, "a replaced toast must deliver its completion at replacement time")
        XCTAssertEqual(toasts().count, 1, "toasts must not stack — the newer one replaces the older")
        XCTAssertEqual(labelTexts(in: toasts()[0]), ["second"], "the surviving toast must be the newest one")
    }

    // MARK: - Touch transparency

    func test_toast_isTouchTransparent() {
        Toast.present(with: "see-through")
        host.layoutIfNeeded()

        guard let toast = toasts().first else { return XCTFail("toast must be installed") }
        let pointInToast = host.convert(CGPoint(x: toast.bounds.midX, y: toast.bounds.midY), from: toast)
        let hit = host.hitTest(pointInToast, with: nil)

        XCTAssertFalse(hit?.isDescendant(of: toast) ?? false, "touches inside the toast strip must fall through to the view beneath")
        XCTAssertFalse(toast.isUserInteractionEnabled, "the toast container must not intercept any interaction")
    }
}
