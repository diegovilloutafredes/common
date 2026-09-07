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

    /// One tap does both: the count is state read in the hook, the confirmation is a
    /// `ViewEvent` the same hook consumes once through its cursor.
    func test_saveDraft_rendersStateInTheHookAndFiresTheEventOnce() {
        let button = app.buttons["Save draft"]
        scrollUntilVisible(button)
        XCTAssertTrue(app.staticTexts["Saves: 0"].exists)

        button.tap()

        XCTAssertTrue(app.staticTexts["Saves: 1"].waitForExistence(timeout: uiTimeout))
        let snackbar = app.staticTexts["Draft saved"]
        XCTAssertTrue(snackbar.waitForExistence(timeout: uiTimeout))

        // Once-ness: after the snackbar dismisses, a hook re-run (Increment mutates observed
        // state) must not bring it back — the cursor already consumed that event's id.
        XCTAssertTrue(snackbar.waitForNonExistence(timeout: uiTimeout))
        let increment = app.buttons["Increment"]
        scrollUntilVisible(increment)
        increment.tap()
        XCTAssertTrue(app.staticTexts["Count: 1"].waitForExistence(timeout: uiTimeout))
        XCTAssertFalse(snackbar.exists)

        // A second firing is a new event: it shows again.
        scrollUntilVisible(button)
        button.tap()
        XCTAssertTrue(app.staticTexts["Saves: 2"].waitForExistence(timeout: uiTimeout))
        XCTAssertTrue(snackbar.waitForExistence(timeout: uiTimeout))
    }

    /// Membership changes go through the tracked revision: adding a row reloads the list and
    /// re-renders the badge, removing it takes both back. Row taps (item mutations) never reload.
    func test_addAndRemoveMessage_reloadThroughRevision() {
        let add = app.buttons["Add message"]
        scrollUntilVisible(add)
        add.tap()
        XCTAssertTrue(app.staticTexts["Message #5"].waitForExistence(timeout: uiTimeout))
        XCTAssertTrue(app.staticTexts["4 unread"].waitForExistence(timeout: uiTimeout))

        app.buttons["Remove last"].tap()
        XCTAssertTrue(app.staticTexts["Message #5"].waitForNonExistence(timeout: uiTimeout))
        XCTAssertTrue(app.staticTexts["3 unread"].waitForExistence(timeout: uiTimeout))
    }

    /// The bar's width constraint constant is written in the hook from a tracked Bool; the tap
    /// mutates inside an animation block, so the frame must settle at the new constant.
    func test_toggleWidth_drivesConstraintFromObservedState() {
        let button = app.buttons["Toggle width"]
        scrollUntilVisible(button)
        let bar = app.otherElements["observation.bar"]
        XCTAssertTrue(bar.waitForExistence(timeout: uiTimeout))
        XCTAssertTrue(app.staticTexts["bar.width = 80"].exists)
        XCTAssertEqual(bar.frame.width, 80, accuracy: 1)

        button.tap()
        XCTAssertTrue(app.staticTexts["bar.width = 240"].waitForExistence(timeout: uiTimeout))
        wait(for: [expectation(for: NSPredicate { _, _ in abs(bar.frame.width - 240) < 1 }, evaluatedWith: nil)], timeout: uiTimeout)

        button.tap()
        XCTAssertTrue(app.staticTexts["bar.width = 80"].waitForExistence(timeout: uiTimeout))
        wait(for: [expectation(for: NSPredicate { _, _ in abs(bar.frame.width - 80) < 1 }, evaluatedWith: nil)], timeout: uiTimeout)
    }
}
