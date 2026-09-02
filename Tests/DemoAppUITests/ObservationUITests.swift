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

    /// Rows self-size: the long preview must be measured with its text already bound (it
    /// wraps to several lines), otherwise the row is clipped to the single-line estimate.
    func test_messageRows_selfSizeToTheirBoundContent() {
        let short = app.staticTexts["Can you review the Observation PR?"]
        let long = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'updateContent() replaced'")).firstMatch
        XCTAssertTrue(short.waitForExistence(timeout: uiTimeout))
        scrollUntilVisible(long)
        XCTAssertTrue(long.waitForExistence(timeout: uiTimeout))
        XCTAssertGreaterThan(long.frame.height, short.frame.height * 1.8, "the wrapped preview must get its full height")
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
