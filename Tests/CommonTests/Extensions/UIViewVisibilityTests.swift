//
//  UIViewVisibilityTests.swift
//

import XCTest
@testable import Common

/// `hide(animated:)` and `show(animated:)` when calls overlap or have nothing to do.
@MainActor
final class UIViewVisibilityTests: XCTestCase {

    private var window: UIWindow!

    override func setUp() {
        super.setUp()
        window = UIWindow(frame: .init(x: 0, y: 0, width: 320, height: 640))
        window.makeKeyAndVisible()
    }

    override func tearDown() {
        window.isHidden = true
        window = nil
        super.tearDown()
    }

    private func makeView(hidden: Bool) -> UIView {
        let view = UIView(frame: .init(x: 0, y: 0, width: 50, height: 50))
        view.isHidden = hidden
        view.alpha = hidden ? 0 : 1
        window.addSubview(view)
        return view
    }

    /// The defect: `show` returned early while a hide animation was still running, and the hide's completion then
    /// hid the view, so the last call lost.
    func test_showDuringAnimatedHide_leavesViewVisible() {
        let view = makeView(hidden: false)
        let hidden = expectation(description: "hide completion")

        view.hide(animated: true, with: 0.1) { hidden.fulfill() }
        view.show(animated: false)
        wait(for: [hidden], timeout: 5)

        XCTAssertFalse(view.isHidden, "the later show must win")
        XCTAssertEqual(view.alpha, 1)
    }

    func test_hideDuringAnimatedShow_leavesViewHidden() {
        let view = makeView(hidden: true)
        let shown = expectation(description: "show completion")

        view.show(animated: true, with: 0.1) { shown.fulfill() }
        view.hide(animated: false)
        wait(for: [shown], timeout: 5)

        XCTAssertTrue(view.isHidden, "the later hide must win")
    }

    /// The defect: a call with nothing to do returned without calling its completion.
    func test_hideOnHiddenView_completesOnce() {
        let view = makeView(hidden: true)
        var completions = 0

        view.hide { completions += 1 }

        XCTAssertEqual(completions, 1)
        XCTAssertTrue(view.isHidden)
    }

    func test_showOnVisibleView_completesOnce() {
        let view = makeView(hidden: false)
        var completions = 0

        view.show { completions += 1 }

        XCTAssertEqual(completions, 1)
        XCTAssertFalse(view.isHidden)
    }

    func test_supersededHide_andItsShow_eachCompleteOnce() {
        let view = makeView(hidden: false)
        var hideCompletions = 0, showCompletions = 0
        let hidden = expectation(description: "hide completion")
        let shown = expectation(description: "show completion")

        view.hide(animated: true, with: 0.1) { hideCompletions += 1; hidden.fulfill() }
        view.show(animated: true, with: 0.1) { showCompletions += 1; shown.fulfill() }
        wait(for: [hidden, shown], timeout: 5)

        XCTAssertEqual(hideCompletions, 1)
        XCTAssertEqual(showCompletions, 1)
        XCTAssertFalse(view.isHidden)
        XCTAssertEqual(view.alpha, 1)
    }
}
