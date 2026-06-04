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

    /// One parameterized test replaces the seven near-identical per-module push/pop tests.
    /// The coordinator push/pop/set mechanics themselves are exhaustively unit-tested in
    /// BaseCoordinatorTests; this only confirms each module is wired into the live app and
    /// returns home on back.
    func test_navigation_eachModule_pushesAndPopsBackHome() {
        let modules = [
            "Declarative UI", "Networking", "Storage",
            "Extensions", "Lists & Cells", "Onboarding", "Utilities"
        ]
        for module in modules {
            // Modules sit at different scroll offsets; reset to top, then reveal this one.
            for _ in 0..<8 { app.swipeDown() }
            scrollUntilVisible(app.staticTexts[module])
            app.staticTexts[module].tap()

            let backButton = app.navigationBars.buttons.firstMatch
            XCTAssertTrue(backButton.waitForExistence(timeout: 10), "Back button should appear after pushing \(module)")
            backButton.tap()

            XCTAssertTrue(app.staticTexts[module].waitForExistence(timeout: 5), "Should return home after popping \(module)")
        }
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

    /// Verifies the Local Authentication screen renders its nav bar + primary control.
    /// Layout correctness ("not stretched") is a visual check via the attached screenshot —
    /// it is not (and cannot be) programmatically asserted via XCUITest.
    func test_localAuth_screenRenders() {
        app.staticTexts["Local Authentication"].tap()
        XCTAssertTrue(app.navigationBars["Local Authentication"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Authenticate"].exists, "Authenticate button should render")
        add(XCTAttachment(screenshot: app.screenshot()))
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

    // MARK: - Utilities

    func test_utilities_sectionTitlesVisible() {
        navigateToUtilities()
        XCTAssertTrue(app.staticTexts["Debouncer.debounce(seconds:function:)"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["UIDatePicker.onValueChanged(_:)"].exists)
        XCTAssertTrue(app.staticTexts["CircularActivityIndicatorView"].exists)
        scrollUntilVisible(app.staticTexts["UIView.animate — properties & constraint"])
        XCTAssertTrue(app.staticTexts["UIView.animate — properties & constraint"].exists)
        add(XCTAttachment(screenshot: app.screenshot()))
    }

    /// XCUITest cannot read a view's alpha, so this is a smoke test: triggering the fade
    /// animation must not crash the screen and the control must stay responsive afterward.
    func test_utilities_fadeAnimation_doesNotCrash() {
        navigateToUtilities()
        scrollUntilVisible(app.buttons["Fade"])
        let fade = app.buttons["Fade"]
        fade.tap()
        XCTAssertTrue(fade.waitForExistence(timeout: 2), "Fade control must remain after the animation")
        XCTAssertTrue(fade.isHittable, "Fade control must stay responsive after the animation")
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

    func test_lists_pullToRefresh_addsSixItems() {
        navigateToLists()
        // The "ALL ITEMS" header reflects the item count; it starts at 15.
        scrollUntilVisible(app.staticTexts["ALL ITEMS (15)"])
        XCTAssertTrue(app.staticTexts["ALL ITEMS (15)"].exists, "List should start with 15 items")

        // Return to the top, then trigger pull-to-refresh with a deliberate long drag — a quick
        // swipeDown doesn't pull far enough to trip UIRefreshControl. Refresh prepends 6 items.
        let list = app.collectionViews.firstMatch
        for _ in 0..<8 { list.swipeDown() }
        let top = list.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let bottom = list.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.95))
        top.press(forDuration: 0.1, thenDragTo: bottom)

        // The header count must grow 15 -> 21 after the 1.2s refresh. Give it time before
        // scrolling away, then scroll down to the (moved) section header if needed.
        let updatedHeader = app.staticTexts["ALL ITEMS (21)"]
        var swipes = 0
        while !updatedHeader.waitForExistence(timeout: 2) && swipes < 8 {
            app.swipeUp()
            swipes += 1
        }
        XCTAssertTrue(updatedHeader.exists,
                      "Pull-to-refresh must add 6 items — header should read ALL ITEMS (21)")
    }

    // MARK: - Forms & TextFields — FieldsValidator

    func test_forms_crossFieldValidation_andSubmitGating() {
        navigateToForms()

        let submit = app.buttons["Submit"]
        XCTAssertTrue(submit.waitForExistence(timeout: 5))
        XCTAssertFalse(submit.isEnabled, "Submit should start disabled on an empty form")

        let name = app.textFields["Full Name"]
        let email = app.textFields["Email Address"]
        let password = app.secureTextFields["Password (min 6 chars)"]
        let confirm = app.secureTextFields["Confirm Password"]

        name.tap(); name.typeText("Jane")
        email.tap(); email.typeText("jane@example.com")
        password.tap(); password.typeText("secret1")
        confirm.tap(); confirm.typeText("secret2") // mismatch

        // Cross-field .matches fails → error shown, submit still disabled.
        XCTAssertTrue(app.staticTexts["Passwords must match"].waitForExistence(timeout: 3))
        XCTAssertFalse(submit.isEnabled)

        // Fix the confirmation → error clears reactively, submit enables.
        confirm.tap()
        confirm.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 8))
        confirm.typeText("secret1")

        XCTAssertTrue(app.staticTexts["Passwords must match"].waitForNonExistence(timeout: 3))
        XCTAssertTrue(submit.isEnabled, "Submit should enable once every field is valid")
    }
}

// MARK: - Extensions helpers

private extension DemoAppUITests {

    func navigateToExtensions() {
        app.staticTexts["Extensions"].tap()
        XCTAssertTrue(app.navigationBars["Extensions"].waitForExistence(timeout: 3))
    }

    func navigateToLists() {
        scrollUntilVisible(app.staticTexts["Lists & Cells"])
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

// MARK: - Forms helpers

private extension DemoAppUITests {

    func navigateToForms() {
        let forms = app.staticTexts["Forms & TextFields"]
        let submit = app.buttons["Submit"]
        // The cell sits low in the home list; a tap can miss during scroll momentum.
        // Retry: tap, wait for the screen, and on miss reset to the top and try again.
        for _ in 0..<4 {
            scrollUntilVisible(forms)
            forms.tap()
            if submit.waitForExistence(timeout: 4) { return }
            for _ in 0..<10 { app.swipeDown() }
        }
        XCTAssertTrue(submit.waitForExistence(timeout: 4), "Forms screen failed to open")
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
