//
//  AlertsUITests.swift
//

import XCTest

// MARK: - AlertsUITests

final class AlertsUITests: UITestCase {

    override func setUp() {
        super.setUp()
        openModule("Alerts & Feedback", until: app.navigationBars["Alerts & Feedback"])
    }

    /// The custom alert is a `ViewEvent`: the view model fires it and the controller presents
    /// it from inside `updateContent()` — on iOS 26 that is UIKit's `updateProperties()` pass.
    /// A second tap is a new event, so the alert presents again after dismissal.
    func test_customAlert_presentsFromTheHookAndAgainOnASecondTap() {
        let button = app.buttons["Basic Alert (icon + confirm)"]
        scrollUntilVisible(button)

        button.tap()
        let title = app.staticTexts["Notification"]
        XCTAssertTrue(title.waitForExistence(timeout: uiTimeout))

        app.buttons["Got it"].tap()
        XCTAssertTrue(title.waitForNonExistence(timeout: uiTimeout))

        button.tap()
        XCTAssertTrue(title.waitForExistence(timeout: uiTimeout))
        app.buttons["Got it"].tap()
        XCTAssertTrue(title.waitForNonExistence(timeout: uiTimeout))
    }
}
