//
//  DemoAppUITests.swift
//

import XCTest

final class DemoAppUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: - Navigation

    func test_homeScreen_showsAllModules() {
        XCTAssertTrue(app.staticTexts["Declarative UI"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Networking"].exists)
        XCTAssertTrue(app.staticTexts["Storage"].exists)
        XCTAssertTrue(app.staticTexts["Alerts & Feedback"].exists)
        XCTAssertTrue(app.staticTexts["Extensions"].exists)
    }

    func test_navigation_pushAndPopDeclarativeUI() {
        app.staticTexts["Declarative UI"].tap()
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 10), "Back button should appear after push")
        backButton.tap()
        XCTAssertTrue(app.staticTexts["Declarative UI"].waitForExistence(timeout: 5), "Should return to home")
    }

    func test_navigation_pushAndPopNetworking() {
        app.staticTexts["Networking"].tap()
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()
        XCTAssertTrue(app.staticTexts["Networking"].waitForExistence(timeout: 3))
    }

    // MARK: - Networking — fetch via callback path

    func test_networking_callbackFetch_loadsOrShowsMock() {
        app.staticTexts["Networking"].tap()
        XCTAssertTrue(app.buttons["Fetch Posts"].waitForExistence(timeout: 3))

        app.buttons["Fetch Posts"].tap()

        let defaultStatus = "Tap Fetch to load posts from JSONPlaceholder API"
        let statusChanged = NSPredicate(format: "label != %@", defaultStatus)
        let statusLabel = app.staticTexts.matching(statusChanged).firstMatch
        XCTAssertTrue(statusLabel.waitForExistence(timeout: 15), "Status should update after fetch")

        XCTAssertGreaterThan(app.cells.count, 0, "Post list should be non-empty")
    }

    // MARK: - Networking — fetch via async path

    func test_networking_asyncFetch_loadsOrShowsMock() {
        app.staticTexts["Networking"].tap()
        XCTAssertTrue(app.buttons["Fetch Posts"].waitForExistence(timeout: 3))

        let segment = app.segmentedControls.firstMatch
        XCTAssertTrue(segment.waitForExistence(timeout: 3))
        segment.buttons["Async"].tap()

        app.buttons["Fetch Posts"].tap()

        let defaultStatus = "Tap Fetch to load posts from JSONPlaceholder API"
        let statusChanged = NSPredicate(format: "label != %@", defaultStatus)
        let statusLabel = app.staticTexts.matching(statusChanged).firstMatch
        XCTAssertTrue(statusLabel.waitForExistence(timeout: 15), "Status should update after async fetch")

        XCTAssertGreaterThan(app.cells.count, 0, "Post list should be non-empty")
    }

    func test_navigation_pushAndPopStorage() {
        app.staticTexts["Storage"].tap()
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()
        XCTAssertTrue(app.staticTexts["Storage"].waitForExistence(timeout: 3))
    }

    // MARK: - Storage — UserDefaults

    func test_storage_userDefaults_saveReadDelete() {
        navigateToStorage()
        exerciseStorageBackend(index: 0, name: "UserDefaults")
    }

    // MARK: - Storage — FileStorage

    func test_storage_fileStorage_saveReadDelete() {
        navigateToStorage()
        let fileStorageSave = app.buttons.matching(identifier: "Save").element(boundBy: 1)
        while !fileStorageSave.isHittable { app.swipeUp() }
        exerciseStorageBackend(index: 1, name: "FileStorage")
    }

    // MARK: - Storage — Keychain

    func test_storage_keychain_saveReadDelete() {
        navigateToStorage()
        // Scroll until the Keychain Save button is hittable
        let keychainSave = app.buttons.matching(identifier: "Save").element(boundBy: 2)
        while !keychainSave.isHittable { app.swipeUp() }
        exerciseStorageBackend(index: 2, name: "Keychain", readPrefixes: ["Read:", "Nothing stored in"])
    }

    func test_navigation_pushAndPopExtensions() {
        app.staticTexts["Extensions"].tap()
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()
        XCTAssertTrue(app.staticTexts["Extensions"].waitForExistence(timeout: 3))
    }

    func test_navigation_pushAndPopOnboarding() {
        app.staticTexts["Onboarding"].tap()
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()
        XCTAssertTrue(app.staticTexts["Onboarding"].waitForExistence(timeout: 3))
    }
}

// MARK: - Storage helpers

private extension DemoAppUITests {

    func navigateToStorage() {
        app.staticTexts["Storage"].tap()
        XCTAssertTrue(app.staticTexts["UserDefaults"].waitForExistence(timeout: 3))
    }

    func exerciseStorageBackend(index: Int, name: String, readPrefixes: [String] = ["Read:"]) {
        let save   = app.buttons.matching(identifier: "Save").element(boundBy: index)
        let read   = app.buttons.matching(identifier: "Read").element(boundBy: index)
        let delete = app.buttons.matching(identifier: "Delete").element(boundBy: index)

        XCTAssertTrue(save.waitForExistence(timeout: 3), "\(name) Save button should exist")

        save.tap()
        waitForSnackbar(prefixes: ["Saved to"], label: "Save", backend: name)

        read.tap()
        waitForSnackbar(prefixes: readPrefixes, label: "Read", backend: name)

        delete.tap()
        waitForSnackbar(prefixes: ["Deleted from"], label: "Delete", backend: name)
    }

    func waitForSnackbar(prefixes: [String], label: String, backend: String) {
        let subpredicates = prefixes.map { NSPredicate(format: "label BEGINSWITH %@", $0) }
        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: subpredicates)
        let snackbar = app.staticTexts.matching(predicate).firstMatch
        XCTAssertTrue(snackbar.waitForExistence(timeout: 5), "\(label) snackbar should appear for \(backend)")
        expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: snackbar)
        waitForExpectations(timeout: 5)
    }
}
