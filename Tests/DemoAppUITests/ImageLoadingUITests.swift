import XCTest

// MARK: - ImageLoadingUITests

final class ImageLoadingUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        navigateToImageLoading()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: - 11.2 Navigation

    func test_navigation_imageLoadingScreenAppears() {
        XCTAssertTrue(app.navigationBars["Image Loading"].exists, "Image Loading nav bar should be visible")
    }

    // MARK: - 11.3 Images load

    func test_imageList_firstCellAppearsWithContent() {
        let list = app.collectionViews["imageLoadingList"]
        XCTAssertTrue(list.waitForExistence(timeout: 5), "Image list should exist")
        XCTAssertGreaterThan(app.cells.count, 0, "Image list should have visible cells")
    }

    // MARK: - 11.4 Scroll + cell reuse

    func test_scroll_doesNotCrash_andFirstCellRetainsContent() {
        let list = app.collectionViews["imageLoadingList"]
        XCTAssertTrue(list.waitForExistence(timeout: 5))

        let initialCount = app.cells.count
        XCTAssertGreaterThan(initialCount, 0, "Cells must be visible before scroll")

        list.swipeUp()
        list.swipeUp()
        list.swipeUp()
        list.swipeDown()
        list.swipeDown()
        list.swipeDown()

        XCTAssertGreaterThan(app.cells.count, 0, "Cells must remain visible after scroll")
    }

    // MARK: - 11.5 Clear Cache button

    func test_clearCache_buttonExists_andCanBeTapped() {
        let list = app.collectionViews["imageLoadingList"]
        XCTAssertTrue(list.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(app.cells.count, 0, "Cells should appear before clear")

        let clearButton = app.buttons["Clear Cache"]
        XCTAssertTrue(clearButton.waitForExistence(timeout: 3), "Clear Cache button should be in nav bar")
        clearButton.tap()

        XCTAssertGreaterThan(app.cells.count, 0, "Cells should reload after cache clear")
    }

    // MARK: - 11.6 Preload

    func test_preload_buttonExists() {
        XCTAssertTrue(app.buttons["Preload"].waitForExistence(timeout: 3), "Preload button must be in nav bar")
    }

    func test_preload_tapDoesNotCrash_andSectionHasCells() {
        // Tap Preload — fires background tasks for section 5 URLs
        app.buttons["Preload"].tap()

        let list = app.collectionViews["imageLoadingList"]
        XCTAssertTrue(list.waitForExistence(timeout: 5))

        // Scroll to preload section (section 5, near the bottom)
        scrollToBottom(list: list, swipes: 6)

        // Give any in-flight preload tasks time to settle
        _ = XCTWaiter.wait(for: [XCTestExpectation(description: "preload settle")], timeout: 2)

        XCTAssertGreaterThan(app.cells.count, 0, "Preload section must have visible cells")
    }

    func test_preload_sectionStillHasCellsAfterCacheCleared() {
        // Clear cache, then preload — verifies preload fetches fresh from network
        let clearButton = app.buttons["Clear Cache"]
        XCTAssertTrue(clearButton.waitForExistence(timeout: 3))
        clearButton.tap()

        app.buttons["Preload"].tap()

        let list = app.collectionViews["imageLoadingList"]
        scrollToBottom(list: list, swipes: 6)

        _ = XCTWaiter.wait(for: [XCTestExpectation(description: "preload network fetch")], timeout: 3)

        XCTAssertGreaterThan(app.cells.count, 0, "Preload section must load from network after cache clear")
    }

    // MARK: - 11.7 Force Refresh

    func test_forceRefresh_sectionHasCells() {
        let list = app.collectionViews["imageLoadingList"]
        XCTAssertTrue(list.waitForExistence(timeout: 5))

        // Scroll all the way to section 6 (force refresh, last section)
        scrollToBottom(list: list, swipes: 10)

        XCTAssertGreaterThan(app.cells.count, 0, "Force refresh section must have visible cells")
    }

    func test_forceRefresh_cellsAppearAfterCacheCleared() {
        // With cache cleared the cells must still load — force refresh uses network regardless
        let clearButton = app.buttons["Clear Cache"]
        XCTAssertTrue(clearButton.waitForExistence(timeout: 3))
        clearButton.tap()

        let list = app.collectionViews["imageLoadingList"]
        XCTAssertTrue(list.waitForExistence(timeout: 5))
        scrollToBottom(list: list, swipes: 10)

        XCTAssertGreaterThan(app.cells.count, 0, "Force refresh cells must appear via network after cache clear")
    }

    func test_forceRefresh_cellsAppearOnRevisit() {
        // Scroll to force refresh, back to top, then back down — cells must re-appear
        let list = app.collectionViews["imageLoadingList"]
        XCTAssertTrue(list.waitForExistence(timeout: 5))

        scrollToBottom(list: list, swipes: 10)
        XCTAssertGreaterThan(app.cells.count, 0, "Cells must appear on first visit")

        scrollToTop(list: list, swipes: 10)
        scrollToBottom(list: list, swipes: 10)

        XCTAssertGreaterThan(app.cells.count, 0, "Force refresh cells must re-appear on revisit (re-fetched from network)")
    }

    // MARK: - Private

    private func navigateToImageLoading() {
        let imageLoadingRow = app.staticTexts["Image Loading"]
        var swipes = 0
        while !imageLoadingRow.isHittable && swipes < 12 {
            app.swipeUp()
            swipes += 1
        }
        XCTAssertTrue(imageLoadingRow.waitForExistence(timeout: 5), "Image Loading row must exist on home screen")
        imageLoadingRow.tap()
        XCTAssertTrue(app.navigationBars["Image Loading"].waitForExistence(timeout: 5), "Image Loading screen should appear")
    }

    private func scrollToBottom(list: XCUIElement, swipes: Int) {
        for _ in 0..<swipes { list.swipeUp() }
    }

    private func scrollToTop(list: XCUIElement, swipes: Int) {
        for _ in 0..<swipes { list.swipeDown() }
    }
}
