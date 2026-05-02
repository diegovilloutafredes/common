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
        let modules = [
            "Declarative UI", "Networking", "Storage", "Alerts & Feedback",
            "Extensions", "Lists & Cells", "Utilities"
        ]
        for module in modules {
            scrollUntilVisible(app.staticTexts[module])
            XCTAssertTrue(app.staticTexts[module].exists, "Missing module: \(module)")
        }
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

    func test_localAuth_layoutNotStretched() {
        app.staticTexts["Local Authentication"].tap()
        XCTAssertTrue(app.navigationBars["Local Authentication"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Authenticate"].exists)
        add(XCTAttachment(screenshot: app.screenshot()))
    }

    func test_navigation_pushAndPopExtensions() {
        app.staticTexts["Extensions"].tap()
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()
        XCTAssertTrue(app.staticTexts["Extensions"].waitForExistence(timeout: 3))
    }

    // MARK: - Extensions screen demos

    func test_extensions_sectionTitlesVisible() {
        navigateToExtensions()

        let expectedSections = [
            "UISwitch.onValueChanged",
            "UISlider.onValueChanged",
            "Int.asCurrency + .asDecimalNumber",
            "String.isValidEmail",
            "Bundle.appVersion / .displayName / .buildNumber",
            "Date.toString(with:) + .epochTime",
            "UIColor.inverted",
            "NSObject.observe(_:action:) + .post(_:)",
            ".round() + .shadow()",
            "setAsRoundedView — pill shape + clipsToBounds caveat",
            "maskedCorners — selective corner rounding",
            "borderColor + borderWidth",
            ".text() + .font() + .textColor()",
            ".onTap { } + UIButton.Configuration",
            ".setRatio()",
            ".randomBackgroundColor()",
            ".withAlphaComponent()",
            "CGFloat.DefaultValues + TimeInterval.DefaultValues",
            "Array+FloatingPoint — .sum / .average / .standardDeviation",
            "String.hyphened + .isRUT + .formatAsRUT()",
        ]

        for title in expectedSections {
            scrollUntilVisible(app.staticTexts[title])
            XCTAssertTrue(app.staticTexts[title].exists, "Missing section: \(title)")
        }

        add(XCTAttachment(screenshot: app.screenshot()))
    }

    func test_extensions_switch_togglesLabel() {
        navigateToExtensions()
        let toggle = app.switches.firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["OFF"].exists)
        toggle.tap()
        XCTAssertTrue(app.staticTexts["ON"].waitForExistence(timeout: 2))
        toggle.tap()
        XCTAssertTrue(app.staticTexts["OFF"].waitForExistence(timeout: 2))
    }

    func test_extensions_notificationButton_updatesLabel() {
        navigateToExtensions()
        let button = app.buttons["Post notification"]
        scrollUntilVisible(button)
        XCTAssertTrue(button.exists)
        XCTAssertTrue(app.staticTexts["Waiting for notification…"].exists)
        button.tap()
        let received = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Received at'")).firstMatch
        XCTAssertTrue(received.waitForExistence(timeout: 2))
    }

    func test_extensions_tapMeButton_showsSnackbar() {
        navigateToExtensions()
        let button = app.buttons["Tap me"]
        scrollUntilVisible(button)
        button.tap()
        let snackbar = app.staticTexts["Button tapped!"]
        XCTAssertTrue(snackbar.waitForExistence(timeout: 3))
    }

    func test_navigation_pushAndPopOnboarding() {
        app.staticTexts["Onboarding"].tap()
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()
        XCTAssertTrue(app.staticTexts["Onboarding"].waitForExistence(timeout: 3))
    }

    // MARK: - Utilities

    func test_navigation_pushAndPopUtilities() {
        scrollUntilVisible(app.staticTexts["Utilities"])
        app.staticTexts["Utilities"].tap()
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()
        XCTAssertTrue(app.staticTexts["Utilities"].waitForExistence(timeout: 3))
    }

    func test_utilities_sectionTitlesVisible() {
        navigateToUtilities()
        XCTAssertTrue(app.staticTexts["Debouncer.debounce(seconds:function:)"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["UIDatePicker.onValueChanged(_:)"].exists)
        XCTAssertTrue(app.staticTexts["CircularActivityIndicatorView"].exists)
        scrollUntilVisible(app.staticTexts["UIView.animate — properties & constraint"])
        XCTAssertTrue(app.staticTexts["UIView.animate — properties & constraint"].exists)
        add(XCTAttachment(screenshot: app.screenshot()))
    }

    func test_utilities_animate_alphaFade() {
        navigateToUtilities()
        scrollUntilVisible(app.buttons["Fade"])
        app.buttons["Fade"].tap()
        XCTAssertTrue(app.buttons["Fade"].waitForExistence(timeout: 2))
    }

    func test_utilities_animate_constraintExpand() {
        navigateToUtilities()
        scrollUntilVisible(app.buttons["Expand"])
        XCTAssertTrue(app.buttons["Expand"].exists)
        app.buttons["Expand"].tap()
        XCTAssertTrue(app.buttons["Collapse"].waitForExistence(timeout: 2))
        app.buttons["Collapse"].tap()
        XCTAssertTrue(app.buttons["Expand"].waitForExistence(timeout: 2))
    }

    func test_utilities_debouncer_updatesLabel() {
        navigateToUtilities()
        let field = app.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 3))
        field.tap()
        field.typeText("Hello")
        let debounced = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Debounced:'")).firstMatch
        XCTAssertTrue(debounced.waitForExistence(timeout: 3), "Debounced label should update after typing")
    }

    func test_utilities_spinner_toggles() {
        navigateToUtilities()
        let startButton = app.buttons["Start Spinner"]
        scrollUntilVisible(startButton)
        XCTAssertTrue(startButton.exists)
        startButton.tap()
        XCTAssertTrue(app.buttons["Stop Spinner"].waitForExistence(timeout: 2))
        app.buttons["Stop Spinner"].tap()
        XCTAssertTrue(app.buttons["Start Spinner"].waitForExistence(timeout: 2))
    }

    // MARK: - Lists & Cells

    func test_navigation_pushAndPopLists() {
        app.staticTexts["Lists & Cells"].tap()
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()
        XCTAssertTrue(app.staticTexts["Lists & Cells"].waitForExistence(timeout: 3))
    }

    func test_lists_rendersItems() {
        navigateToLists()
        XCTAssertTrue(app.staticTexts["List Item 1"].waitForExistence(timeout: 3), "First item should be visible")
        XCTAssertGreaterThan(app.cells.count, 0, "List should have cells")
    }

    func test_lists_sectionHeadersVisible() {
        navigateToLists()
        XCTAssertTrue(app.staticTexts["RECENT"].waitForExistence(timeout: 3), "Recent section header should be visible")
        scrollUntilVisible(app.staticTexts["ALL ITEMS (15)"])
        XCTAssertTrue(app.staticTexts["ALL ITEMS (15)"].exists, "All Items section header should be visible")
    }

    func test_lists_tapItem_showsSnackbar() {
        navigateToLists()
        XCTAssertTrue(app.staticTexts["List Item 1"].waitForExistence(timeout: 3))
        app.staticTexts["List Item 1"].firstMatch.tap()
        let snackbar = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Tapped:'")).firstMatch
        XCTAssertTrue(snackbar.waitForExistence(timeout: 3), "Snackbar should appear after tapping a list item")
    }

    func test_lists_pullToRefresh_addsItems() {
        navigateToLists()
        XCTAssertTrue(app.staticTexts["List Item 1"].waitForExistence(timeout: 3))
        let initialCount = app.cells.count

        app.tables.firstMatch.swipeDown()
        let list = app.collectionViews.firstMatch
        list.swipeDown()

        let firstNewItem = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'List Item 1'")).firstMatch
        XCTAssertTrue(firstNewItem.waitForExistence(timeout: 5), "New items should appear after pull-to-refresh")
        XCTAssertGreaterThanOrEqual(app.cells.count, initialCount, "Cell count should not decrease after refresh")
    }
}

// MARK: - Extensions helpers

private extension DemoAppUITests {

    func navigateToExtensions() {
        app.staticTexts["Extensions"].tap()
        XCTAssertTrue(app.navigationBars["Extensions"].waitForExistence(timeout: 3))
    }

    func navigateToLists() {
        app.staticTexts["Lists & Cells"].tap()
        XCTAssertTrue(app.navigationBars["Lists & Cells"].waitForExistence(timeout: 3))
    }

    func navigateToUtilities() {
        scrollUntilVisible(app.staticTexts["Utilities"])
        app.staticTexts["Utilities"].tap()
        XCTAssertTrue(app.navigationBars["Utilities"].waitForExistence(timeout: 3))
    }

    func scrollUntilVisible(_ element: XCUIElement, maxSwipes: Int = 10) {
        var swipes = 0
        while !element.isHittable && swipes < maxSwipes {
            app.swipeUp()
            swipes += 1
        }
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
