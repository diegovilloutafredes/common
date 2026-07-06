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
        XCTAssertTrue(app.navigationBars["Child Flow"].waitForExistence(timeout: 3))
        XCTAssertEqual(statLabel("childStat.depth").label, "1")
        XCTAssertEqual(statLabel("childStat.remaining").label, "0")
    }

    func test_launchChild_goDeeperButtonHidden() {
        app.buttons["Launch Child"].tap()
        XCTAssertTrue(app.navigationBars["Child Flow"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["Go Deeper"].exists, "Go Deeper should be hidden when maxDepth=1")
    }

    func test_launchChild_statsIncrement() {
        app.buttons["Launch Child"].tap()
        XCTAssertTrue(app.navigationBars["Child Flow"].waitForExistence(timeout: 3))

        let backButton = app.navigationBars["Child Flow"].buttons.firstMatch
        backButton.tap()
        XCTAssertTrue(app.navigationBars["Coordinator Demo"].waitForExistence(timeout: 3))

        XCTAssertEqual(statLabel("stat.events").label, "2", "Start + cancel events = 2")
    }

    // MARK: - Complete child flow

    func test_completeChild_logsFinishedEvent() {
        app.buttons["Launch Child"].tap()
        XCTAssertTrue(app.buttons["Complete"].waitForExistence(timeout: 3))
        app.buttons["Complete"].tap()

        XCTAssertTrue(app.navigationBars["Coordinator Demo"].waitForExistence(timeout: 3))
        XCTAssertEqual(statLabel("stat.events").label, "2", "Start + finish events = 2")
    }

    // MARK: - Deep flow (maxDepth = 3)

    func test_deepFlow_canGoDeeperToDeepFlow() {
        app.buttons["Launch Deep Flow"].tap()
        XCTAssertTrue(app.buttons["Go Deeper"].waitForExistence(timeout: 3))
        app.buttons["Go Deeper"].tap()

        XCTAssertTrue(app.navigationBars["Nested Flow"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Go Deeper"].waitForExistence(timeout: 3))
        app.buttons["Go Deeper"].tap()

        XCTAssertTrue(
            app.navigationBars["Deep Flow"].waitForExistence(timeout: 3),
            "Depth 3 shows 'Deep Flow'"
        )
    }

    func test_deepFlow_goDeeperHiddenAtMaxDepth() {
        app.buttons["Launch Deep Flow"].tap()
        XCTAssertTrue(app.buttons["Go Deeper"].waitForExistence(timeout: 3))
        app.buttons["Go Deeper"].tap()
        XCTAssertTrue(app.navigationBars["Nested Flow"].waitForExistence(timeout: 3))
        app.buttons["Go Deeper"].tap()
        XCTAssertTrue(app.navigationBars["Deep Flow"].waitForExistence(timeout: 3))

        XCTAssertFalse(app.buttons["Go Deeper"].exists, "Go Deeper hidden at max depth")
    }

    func test_deepFlow_completingFullChain_returnsToHub() {
        navigateToDepth3()
        app.buttons["Complete"].tap()
        XCTAssertTrue(app.navigationBars["Nested Flow"].waitForExistence(timeout: 3))
        app.buttons["Complete"].tap()
        XCTAssertTrue(app.navigationBars["Child Flow"].waitForExistence(timeout: 3))
        app.buttons["Complete"].tap()

        XCTAssertTrue(
            app.navigationBars["Coordinator Demo"].waitForExistence(timeout: 3),
            "Completing full 3-level chain returns to hub"
        )
        // The stats are the observable proxy for "three children ran and
        // unwound": every start/finish is an event, and none may linger.
        XCTAssertEqual(statLabel("stat.children").label, "0", "all coordinators must be released after the chain unwinds")
        XCTAssertEqual(statLabel("stat.events").label, "6", "3 starts + 3 finishes")
    }

    // MARK: - Navigation

    func test_canReturnToHome() {
        let backButton = app.navigationBars["Coordinator Demo"].buttons.firstMatch
        XCTAssertTrue(backButton.exists)
        backButton.tap()
        XCTAssertTrue(
            app.navigationBars["Common Demo"].waitForExistence(timeout: 3),
            "Should return to the home screen"
        )
    }
}

// MARK: - Helpers

private extension CoordinatorDemoUITests {
    func navigateToDepth3() {
        app.buttons["Launch Deep Flow"].tap()
        XCTAssertTrue(app.buttons["Go Deeper"].waitForExistence(timeout: 3))
        app.buttons["Go Deeper"].tap()
        XCTAssertTrue(app.navigationBars["Nested Flow"].waitForExistence(timeout: 3))
        app.buttons["Go Deeper"].tap()
        XCTAssertTrue(app.navigationBars["Deep Flow"].waitForExistence(timeout: 3))
    }

    func statLabel(_ id: String) -> XCUIElement {
        app.staticTexts.matching(identifier: id).firstMatch
    }
}
