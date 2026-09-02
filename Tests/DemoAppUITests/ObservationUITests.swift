//
//  ObservationUITests.swift
//

import XCTest

// MARK: - ObservationUITests

final class ObservationUITests: UITestCase {

    override func setUp() {
        super.setUp()
        openModule("Observation", until: app.navigationBars["Observation"])
    }

    /// The buttons mutate an @Observable model only. No didSet, no setNeedsLayout, no
    /// manual label writes exist in the module — a stale label means the hook is broken.
    func test_increment_and_reset_updateCountThroughObservation() {
        let increment = app.buttons["Increment"]
        XCTAssertTrue(increment.waitForExistence(timeout: uiTimeout))
        XCTAssertTrue(app.staticTexts["Count: 0"].exists)

        increment.tap()
        increment.tap()
        increment.tap()
        XCTAssertTrue(app.staticTexts["Count: 3"].waitForExistence(timeout: uiTimeout))

        app.buttons["Reset"].tap()
        XCTAssertTrue(app.staticTexts["Count: 0"].waitForExistence(timeout: uiTimeout))
    }

    /// "Mark all read" flips isRead on every message model. The BaseView badge and the
    /// visible cells refresh through updateContent() with no reloadData.
    func test_markAllRead_refreshesBadgeAndCells() {
        let badge = app.staticTexts["3 unread"]
        XCTAssertTrue(badge.waitForExistence(timeout: uiTimeout))

        let button = app.buttons["Mark all read"]
        scrollUntilVisible(button)
        button.tap()

        XCTAssertTrue(app.staticTexts["0 unread"].waitForExistence(timeout: uiTimeout))
        XCTAssertFalse(app.staticTexts["3 unread"].exists)
    }
}
