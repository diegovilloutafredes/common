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

    // The cache / preload / force-refresh SEMANTICS (cache-first ordering, eviction, dedup,
    // force-refresh-uses-network) are exhaustively covered at the unit level in
    // ImageCacheTests, ImageLoaderTests, and UIImageViewLoadImageTests. These UI tests verify
    // only what the unit tests can't: the screen renders, scrolling all sections doesn't crash,
    // and the nav-bar actions are wired. (XCUITest cannot assert image pixel content.)

    // MARK: - 11.2 Screen renders with cells

    func test_imageLoading_screenAppearsWithCells() {
        XCTAssertTrue(app.navigationBars["Image Loading"].exists, "Image Loading nav bar should be visible")
        let list = app.collectionViews["imageLoadingList"]
        XCTAssertTrue(list.waitForExistence(timeout: 5), "Image list should exist")
        XCTAssertGreaterThan(app.cells.count, 0, "Image list should render cells")
    }

    // MARK: - 11.3 Scrolling every section (cache/preload/force-refresh) doesn't crash

    func test_imageLoading_scrollingAllSections_doesNotCrash() {
        let list = app.collectionViews["imageLoadingList"]
        XCTAssertTrue(list.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(app.cells.count, 0, "Cells must be visible before scroll")

        scrollToBottom(list: list, swipes: 10)
        scrollToTop(list: list, swipes: 10)

        XCTAssertGreaterThan(app.cells.count, 0, "Cells must remain after scrolling through all sections")
    }

    // MARK: - 11.4 Nav-bar actions are wired (Clear Cache + Preload)

    func test_imageLoading_actionButtons_existAndDoNotCrash() {
        let clearCache = app.buttons["Clear Cache"]
        let preload = app.buttons["Preload"]
        XCTAssertTrue(clearCache.waitForExistence(timeout: 3), "Clear Cache action should be wired into the nav bar")
        XCTAssertTrue(preload.waitForExistence(timeout: 3), "Preload action should be wired into the nav bar")

        clearCache.tap()
        preload.tap()

        XCTAssertTrue(app.collectionViews["imageLoadingList"].waitForExistence(timeout: 5),
                      "List must remain functional after cache clear + preload")
        XCTAssertGreaterThan(app.cells.count, 0)
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
