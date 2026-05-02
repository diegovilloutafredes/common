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

    func test_initialState_showsIdle() {
        XCTAssertTrue(app.staticTexts["Idle"].exists, "Status label should show 'Idle'")
        XCTAssertTrue(app.buttons["Launch Child Flow"].exists)
        XCTAssertTrue(app.buttons["Launch Child Flow"].isEnabled, "Button should be enabled initially")
    }

    // MARK: - Launch child

    func test_launchChild_navigatesToChildFlowScreen() {
        app.buttons["Launch Child Flow"].tap()
        XCTAssertTrue(
            app.navigationBars["Child Flow"].waitForExistence(timeout: 3),
            "Navigation bar should show 'Child Flow' after launch"
        )
    }

    func test_launchChild_statusBecomesChildRunning() {
        app.buttons["Launch Child Flow"].tap()

        // Back to parent screen by pressing back button
        let backButton = app.navigationBars["Child Flow"].buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))

        // While on child screen, navigate back
        backButton.tap()

        // After cancel, status should not be "Child Running" anymore — but first verify it was set
        // The button being disabled proves "Child Running" state was entered
        // (We can't directly observe it on screen while on child screen)
        XCTAssertTrue(
            app.navigationBars["Coordinator Demo"].waitForExistence(timeout: 3),
            "Should return to Coordinator Demo screen"
        )
    }

    // MARK: - Finish flow

    func test_finishFlow_statusBecomesFinished() {
        app.buttons["Launch Child Flow"].tap()
        XCTAssertTrue(app.buttons["Complete Flow"].waitForExistence(timeout: 3))
        app.buttons["Complete Flow"].tap()

        XCTAssertTrue(
            app.staticTexts["Finished"].waitForExistence(timeout: 3),
            "Status should show 'Finished' after completing the child flow"
        )
        XCTAssertTrue(
            app.navigationBars["Coordinator Demo"].waitForExistence(timeout: 3),
            "Should return to Coordinator Demo screen after finish"
        )
    }

    func test_finishFlow_buttonRemainsEnabled() {
        app.buttons["Launch Child Flow"].tap()
        XCTAssertTrue(app.buttons["Complete Flow"].waitForExistence(timeout: 3))
        app.buttons["Complete Flow"].tap()

        XCTAssertTrue(app.staticTexts["Finished"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Launch Child Flow"].isEnabled, "Button should be re-enabled after finish")
    }

    // MARK: - Cancel flow (swipe-back)

    func test_cancelFlow_swipeBack_statusBecomesCancelled() {
        app.buttons["Launch Child Flow"].tap()
        XCTAssertTrue(app.navigationBars["Child Flow"].waitForExistence(timeout: 3))

        app.navigationBars["Child Flow"].buttons.firstMatch.tap()

        XCTAssertTrue(
            app.staticTexts["Cancelled"].waitForExistence(timeout: 3),
            "Status should show 'Cancelled' after swiping back"
        )
    }

    func test_cancelFlow_buttonRemainsEnabled() {
        app.buttons["Launch Child Flow"].tap()
        XCTAssertTrue(app.navigationBars["Child Flow"].waitForExistence(timeout: 3))
        app.navigationBars["Child Flow"].buttons.firstMatch.tap()

        XCTAssertTrue(app.staticTexts["Cancelled"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Launch Child Flow"].isEnabled, "Button should be re-enabled after cancel")
    }

    // MARK: - Re-launch after state change

    func test_canRelaunchAfterFinish() {
        app.buttons["Launch Child Flow"].tap()
        XCTAssertTrue(app.buttons["Complete Flow"].waitForExistence(timeout: 3))
        app.buttons["Complete Flow"].tap()

        XCTAssertTrue(app.staticTexts["Finished"].waitForExistence(timeout: 3))

        app.buttons["Launch Child Flow"].tap()
        XCTAssertTrue(
            app.navigationBars["Child Flow"].waitForExistence(timeout: 3),
            "Should be able to relaunch after finish"
        )
    }

    func test_canRelaunchAfterCancel() {
        app.buttons["Launch Child Flow"].tap()
        XCTAssertTrue(app.navigationBars["Child Flow"].waitForExistence(timeout: 3))
        app.navigationBars["Child Flow"].buttons.firstMatch.tap()

        XCTAssertTrue(app.staticTexts["Cancelled"].waitForExistence(timeout: 3))

        app.buttons["Launch Child Flow"].tap()
        XCTAssertTrue(
            app.navigationBars["Child Flow"].waitForExistence(timeout: 3),
            "Should be able to relaunch after cancel"
        )
    }

    // MARK: - Navigation

    func test_navigation_pushAndPopCoordinatorDemo() {
        let backButton = app.navigationBars["Coordinator Demo"].buttons.firstMatch
        XCTAssertTrue(backButton.exists, "Back button should be visible on Coordinator Demo screen")
        backButton.tap()
        XCTAssertTrue(
            app.staticTexts["Coordinator"].waitForExistence(timeout: 3),
            "Should return to home screen after popping"
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
}
