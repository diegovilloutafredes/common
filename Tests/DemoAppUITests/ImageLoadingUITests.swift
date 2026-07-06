import XCTest

// MARK: - ImageLoadingUITests

final class ImageLoadingUITests: UITestCase {

    // Disable the GIF animation so its CADisplayLink can't interfere with XCUITest idle detection.
    override var launchArguments: [String] { ["UI_TESTING"] }

    override func setUp() {
        super.setUp()
        openModule("Image Loading", until: app.navigationBars["Image Loading"])
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
        // The GIF banner must render above the list (the VStack { banner; list }
        // restructure must not collapse either part). This also doubles as the
        // UI_TESTING-gate skip-path check: with the animation gated off, the
        // banner's label is what proves the screen still renders it.
        XCTAssertTrue(
            app.staticTexts["GIFImageView"].waitForExistence(timeout: 5),
            "GIFImageView demo banner should render above the list"
        )
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

    private func scrollToBottom(list: XCUIElement, swipes: Int) {
        for _ in 0..<swipes { list.swipeUp() }
    }

    private func scrollToTop(list: XCUIElement, swipes: Int) {
        for _ in 0..<swipes { list.swipeDown() }
    }
}
