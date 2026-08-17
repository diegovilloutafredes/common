//
//  CoordinatorDemoUITests.swift
//

import XCTest

final class CoordinatorDemoUITests: UITestCase {

    // Six former tests were strict subsets of the survivors (identical walks,
    // weaker assertions, one full app relaunch each): navigate-only variants of
    // showsDepthOne / logsFinishedEvent / statsIncrement / canGoDeeperToDeepFlow,
    // and completingDepth3 ⊂ completingFullChain. Zero detection was lost.

    override func setUp() {
        super.setUp()
        openModule("Coordinator", until: app.navigationBars["Coordinator Demo"])
    }

    // MARK: - Initial state

    func test_initialState_buttonsExist() {
        XCTAssertTrue(app.buttons["Launch Child"].exists)
        XCTAssertTrue(app.buttons["Launch Deep Flow"].exists)
        XCTAssertTrue(app.buttons["Launch Child"].isEnabled)
        XCTAssertTrue(app.buttons["Launch Deep Flow"].isEnabled)
    }

    func test_initialState_statsShowZero() {
        XCTAssertEqual(statLabel("stat.children").label, "0")
        XCTAssertEqual(statLabel("stat.events").label, "0")
    }

    // MARK: - Launch child (maxDepth = 1)

    func test_launchChild_showsDepthOne() {
        app.buttons["Launch Child"].tap()
        XCTAssertTrue(app.navigationBars["Child Flow"].waitForExistence(timeout: uiTimeout))
        XCTAssertEqual(statLabel("childStat.depth").label, "1")
        XCTAssertEqual(statLabel("childStat.remaining").label, "0")
    }

    func test_launchChild_goDeeperButtonHidden() {
        app.buttons["Launch Child"].tap()
        XCTAssertTrue(app.navigationBars["Child Flow"].waitForExistence(timeout: uiTimeout))
        XCTAssertFalse(app.buttons["Go Deeper"].exists, "Go Deeper should be hidden when maxDepth=1")
    }

    func test_launchChild_statsIncrement() {
        app.buttons["Launch Child"].tap()
        XCTAssertTrue(app.navigationBars["Child Flow"].waitForExistence(timeout: uiTimeout))

        let backButton = app.navigationBars["Child Flow"].buttons.firstMatch
        backButton.tap()
        XCTAssertTrue(app.navigationBars["Coordinator Demo"].waitForExistence(timeout: uiTimeout))

        assertStat("stat.events", equals: "2", "Start + cancel events = 2")
    }

    // MARK: - Complete child flow

    func test_completeChild_logsFinishedEvent() {
        app.buttons["Launch Child"].tap()
        XCTAssertTrue(app.buttons["Complete"].waitForExistence(timeout: uiTimeout))
        app.buttons["Complete"].tap()

        XCTAssertTrue(app.navigationBars["Coordinator Demo"].waitForExistence(timeout: uiTimeout))
        assertStat("stat.events", equals: "2", "Start + finish events = 2")
    }

    // MARK: - Deep flow (maxDepth = 3)

    func test_deepFlow_canGoDeeperToDeepFlow() {
        app.buttons["Launch Deep Flow"].tap()
        XCTAssertTrue(app.buttons["Go Deeper"].waitForExistence(timeout: uiTimeout))
        app.buttons["Go Deeper"].tap()

        XCTAssertTrue(app.navigationBars["Nested Flow"].waitForExistence(timeout: uiTimeout))
        XCTAssertTrue(app.buttons["Go Deeper"].waitForExistence(timeout: uiTimeout))
        app.buttons["Go Deeper"].tap()

        XCTAssertTrue(
            app.navigationBars["Deep Flow"].waitForExistence(timeout: uiTimeout),
            "Depth 3 shows 'Deep Flow'"
        )
    }

    func test_deepFlow_goDeeperHiddenAtMaxDepth() {
        app.buttons["Launch Deep Flow"].tap()
        XCTAssertTrue(app.buttons["Go Deeper"].waitForExistence(timeout: uiTimeout))
        app.buttons["Go Deeper"].tap()
        XCTAssertTrue(app.navigationBars["Nested Flow"].waitForExistence(timeout: uiTimeout))
        app.buttons["Go Deeper"].tap()
        XCTAssertTrue(app.navigationBars["Deep Flow"].waitForExistence(timeout: uiTimeout))

        XCTAssertFalse(app.buttons["Go Deeper"].exists, "Go Deeper hidden at max depth")
    }

    func test_deepFlow_completingFullChain_returnsToHub() {
        navigateToDepth3()
        app.buttons["Complete"].tap()
        XCTAssertTrue(app.navigationBars["Nested Flow"].waitForExistence(timeout: uiTimeout))
        app.buttons["Complete"].tap()
        XCTAssertTrue(app.navigationBars["Child Flow"].waitForExistence(timeout: uiTimeout))
        app.buttons["Complete"].tap()

        XCTAssertTrue(
            app.navigationBars["Coordinator Demo"].waitForExistence(timeout: uiTimeout),
            "Completing full 3-level chain returns to hub"
        )
        // The stats are the observable proxy for "three children ran and
        // unwound": every start/finish is an event, and none may linger.
        assertStat("stat.children", equals: "0", "all coordinators must be released after the chain unwinds")
        assertStat("stat.events", equals: "6", "3 starts + 3 finishes")
    }

    // MARK: - Sheet presentation

    func test_presentSheet_andDismissViaCoordinator() {
        app.buttons["Present Sheet"].tap()
        XCTAssertTrue(app.buttons["Dismiss Sheet"].waitForExistence(timeout: uiTimeout),
                      "the coordinator should present the sheet flow")

        app.buttons["Dismiss Sheet"].tap()

        let gone = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: app.buttons["Dismiss Sheet"]
        )
        XCTAssertEqual(XCTWaiter().wait(for: [gone], timeout: uiTimeout), .completed,
                       "the coordinator's dismiss() should remove the sheet")
        // 📤 present + 📥 dismiss
        assertStat("stat.events", equals: "2", "present + dismiss events")
    }

    // MARK: - Abort-all cascade

    func test_abortAll_popsToHubAndAutoCancelsAllChildren() {
        navigateToDepth3()

        app.buttons["Abort All"].tap()

        XCTAssertTrue(app.navigationBars["Coordinator Demo"].waitForExistence(timeout: uiTimeout),
                      "pop(.to(hub)) should land directly on the hub")
        // 3 starts + 1 abort marker + 3 auto-cancels = 7; children back to 0 with
        // zero per-child teardown code — the framework cancels the whole subtree.
        assertStat("stat.children", equals: "0", "every stacked child must auto-cancel")
        assertStat("stat.events", equals: "7", "3 starts + abort marker + 3 cascade cancels")
    }

    // MARK: - Navigation

    func test_canReturnToHome() {
        let backButton = app.navigationBars["Coordinator Demo"].buttons.firstMatch
        XCTAssertTrue(backButton.exists)
        backButton.tap()
        XCTAssertTrue(
            app.navigationBars["Common Demo"].waitForExistence(timeout: uiTimeout),
            "Should return to the home screen"
        )
    }
}

// MARK: - Helpers

private extension CoordinatorDemoUITests {
    func navigateToDepth3() {
        app.buttons["Launch Deep Flow"].tap()
        XCTAssertTrue(app.buttons["Go Deeper"].waitForExistence(timeout: uiTimeout))
        app.buttons["Go Deeper"].tap()
        XCTAssertTrue(app.navigationBars["Nested Flow"].waitForExistence(timeout: uiTimeout))
        app.buttons["Go Deeper"].tap()
        XCTAssertTrue(app.navigationBars["Deep Flow"].waitForExistence(timeout: uiTimeout))
    }

    func statLabel(_ id: String) -> XCUIElement {
        app.staticTexts.matching(identifier: id).firstMatch
    }

    /// Stat labels update when the coordinator's pop-detection event lands,
    /// which can trail the nav-bar reappearing (waitForExistence can return at
    /// pop-animation start) — poll the value instead of one-shot reading it.
    func assertStat(_ id: String, equals expected: String,
                    _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
        let matched = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "label == %@", expected),
            object: statLabel(id)
        )
        let result = XCTWaiter().wait(for: [matched], timeout: uiTimeout)
        XCTAssertEqual(result, .completed,
                       "\(id) should reach \"\(expected)\" — \(message); last value: \(statLabel(id).label)",
                       file: file, line: line)
    }
}
