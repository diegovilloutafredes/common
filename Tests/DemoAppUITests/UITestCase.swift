//
//  UITestCase.swift
//

import XCTest

/// Shared base for the DemoApp UI tests.
///
/// Owns the `XCUIApplication`, launches it (with optional ``launchArguments``), and
/// provides the home-list navigation. The home cell tap can miss during scroll
/// momentum, so ``openModule(_:until:file:line:)`` retries — resetting the list to
/// the top on a miss — which is the resilient path every screen navigates through.
class UITestCase: XCTestCase {

    /// Ceiling for local-UI waits. Waits return as soon as the element appears,
    /// so a generous timeout costs nothing on green runs — only broken runs pay
    /// it. 8s (not 3-4) because full-suite runs degrade the simulator across
    /// ~38 fresh app launches and screens legitimately take longer to appear.
    let uiTimeout: TimeInterval = 8
    /// Ceiling for real-network operations (the Networking module's fetches).
    let networkTimeout: TimeInterval = 15

    /// The FIRST home row's title — the reset-to-top anchor. Degradation on
    /// rename: resetHomeListToTop can no longer detect "already at top" and
    /// burns its full swipe budget per attempt (slow, not failing). Update
    /// together with HomeViewModel's first row.
    static let firstHomeRow = "Declarative UI"
    /// The home screen's nav-bar title (HomeViewModel.title). Degradation on
    /// rename: popBackToHomeIfPushed's confirmation wait times out and the
    /// retry loses its recovery guarantee. Update together with HomeViewModel.
    static let homeNavTitle = "Common Demo"

    var app: XCUIApplication!

    /// Launch arguments for this test class. Override to opt in, e.g. `["UI_TESTING"]`.
    var launchArguments: [String] { [] }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = launchArguments
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: - Home-list navigation

    /// Scrolls the home list up until `element` is hittable (bounded by `maxSwipes`).
    func scrollUntilVisible(_ element: XCUIElement, maxSwipes: Int = 12) {
        var swipes = 0
        while !element.isHittable && swipes < maxSwipes {
            app.swipeUp()
            swipes += 1
        }
    }

    /// Scrolls the home list back to its top, anchored on ``firstHomeRow``
    /// (bounded by `maxSwipes`).
    private func resetHomeListToTop(maxSwipes: Int = 10) {
        let firstRow = app.staticTexts[Self.firstHomeRow]
        var swipes = 0
        while !firstRow.isHittable && swipes < maxSwipes {
            app.swipeDown()
            swipes += 1
        }
    }

    /// After a landmark miss the tap may still have landed on a slow screen. If
    /// a navigation push happened — home has no nav-bar buttons — pop back so
    /// the next attempt starts from home instead of swiping the pushed screen.
    private func popBackToHomeIfPushed() {
        let back = app.navigationBars.buttons.firstMatch
        guard back.exists else { return }
        back.tap()
        _ = app.navigationBars[Self.homeNavTitle].waitForExistence(timeout: 2)
    }

    /// Opens a module from the home list, retrying the cell tap until `landmark`
    /// appears. Each attempt starts from the top of the list, so the target row
    /// is reachable from any scroll position; the tap only fires on a hittable
    /// cell (tapping an unresolved query is a hard XCUITest failure); and a miss
    /// with a pushed screen recovers by popping back home.
    func openModule(
        _ name: String,
        until landmark: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let cell = app.staticTexts[name]
        for _ in 0..<4 {
            resetHomeListToTop()
            scrollUntilVisible(cell)
            guard cell.isHittable else { continue }
            cell.tap()
            if landmark.waitForExistence(timeout: uiTimeout) { return }
            popBackToHomeIfPushed()
        }
        XCTAssertTrue(
            landmark.waitForExistence(timeout: uiTimeout),
            "\(name) screen failed to open",
            file: file,
            line: line
        )
    }
}
