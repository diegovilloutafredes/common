//
//  CoordinatorDemoUITests.swift
//

import XCTest

final class CoordinatorDemoUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        navigateToCoordinatorDemo()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
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

    func test_launchChild_navigatesToChildFlow() {
        app.buttons["Launch Child"].tap()
        XCTAssertTrue(
            app.navigationBars["Child Flow"].waitForExistence(timeout: 3),
            "Should navigate to Child Flow screen"
        )
    }

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

    func test_completeChild_returnsToHub() {
        app.buttons["Launch Child"].tap()
        XCTAssertTrue(app.buttons["Complete"].waitForExistence(timeout: 3))
        app.buttons["Complete"].tap()

        XCTAssertTrue(
            app.navigationBars["Coordinator Demo"].waitForExistence(timeout: 3),
            "Should return to hub after complete"
        )
    }

    func test_completeChild_logsFinishedEvent() {
        app.buttons["Launch Child"].tap()
        XCTAssertTrue(app.buttons["Complete"].waitForExistence(timeout: 3))
        app.buttons["Complete"].tap()

        XCTAssertTrue(app.navigationBars["Coordinator Demo"].waitForExistence(timeout: 3))
        XCTAssertEqual(statLabel("stat.events").label, "2", "Start + finish events = 2")
    }

    // MARK: - Cancel child flow (back button)

    func test_cancelChild_returnsToHub() {
        app.buttons["Launch Child"].tap()
        XCTAssertTrue(app.navigationBars["Child Flow"].waitForExistence(timeout: 3))

        app.navigationBars["Child Flow"].buttons.firstMatch.tap()

        XCTAssertTrue(
            app.navigationBars["Coordinator Demo"].waitForExistence(timeout: 3),
            "Should return to hub after cancel"
        )
    }

    // MARK: - Deep flow (maxDepth = 3)

    func test_deepFlow_navigatesToChildFlow() {
        app.buttons["Launch Deep Flow"].tap()
        XCTAssertTrue(
            app.navigationBars["Child Flow"].waitForExistence(timeout: 3),
            "Deep flow starts at Child Flow (depth 1)"
        )
    }

    func test_deepFlow_canGoDeeperToNestedFlow() {
        app.buttons["Launch Deep Flow"].tap()
        XCTAssertTrue(app.buttons["Go Deeper"].waitForExistence(timeout: 3))
        app.buttons["Go Deeper"].tap()

        XCTAssertTrue(
            app.navigationBars["Nested Flow"].waitForExistence(timeout: 3),
            "Depth 2 shows 'Nested Flow'"
        )
    }

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

    func test_deepFlow_completingDepth3_returnsToDepth2() {
        navigateToDepth3()
        app.buttons["Complete"].tap()

        XCTAssertTrue(
            app.navigationBars["Nested Flow"].waitForExistence(timeout: 3),
            "Completing depth 3 returns to depth 2"
        )
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
    }

    func test_deepFlow_childrenCountReachesThree() {
        app.buttons["Launch Deep Flow"].tap()
        XCTAssertTrue(app.buttons["Go Deeper"].waitForExistence(timeout: 3))
        app.buttons["Go Deeper"].tap()
        XCTAssertTrue(app.navigationBars["Nested Flow"].waitForExistence(timeout: 3))
        app.buttons["Go Deeper"].tap()
        XCTAssertTrue(app.navigationBars["Deep Flow"].waitForExistence(timeout: 3))

        // Return to hub
        app.buttons["Complete"].tap()
        XCTAssertTrue(app.navigationBars["Nested Flow"].waitForExistence(timeout: 3))
        app.buttons["Complete"].tap()
        XCTAssertTrue(app.navigationBars["Child Flow"].waitForExistence(timeout: 3))
        app.buttons["Complete"].tap()
        XCTAssertTrue(app.navigationBars["Coordinator Demo"].waitForExistence(timeout: 3))

        XCTAssertEqual(statLabel("stat.children").label, "0", "All coordinators finished, children=0")
    }

    // MARK: - Navigation

    func test_canReturnToHome() {
        let backButton = app.navigationBars["Coordinator Demo"].buttons.firstMatch
        XCTAssertTrue(backButton.exists)
        backButton.tap()
        XCTAssertTrue(
            app.staticTexts["Coordinator"].waitForExistence(timeout: 3),
            "Should return to home screen"
        )
    }
}

// MARK: - Helpers

private extension CoordinatorDemoUITests {
    func navigateToCoordinatorDemo() {
        let cell = app.staticTexts["Coordinator"]
        var swipes = 0
        while !cell.isHittable && swipes < 10 {
            app.swipeUp()
            swipes += 1
        }
        cell.tap()
        XCTAssertTrue(
            app.navigationBars["Coordinator Demo"].waitForExistence(timeout: 5),
            "Should navigate to Coordinator Demo screen"
        )
    }

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
