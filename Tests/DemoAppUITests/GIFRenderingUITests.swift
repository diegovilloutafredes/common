import XCTest

// MARK: - GIFRenderingUITests

/// The ONLY automated net for the display-suppression bug class (GIFImageView
/// `f966bd7`): frames that decode and tick but never reach the screen. The unit
/// harness is structurally blind to it — mutation-verified: headless windows
/// commit layer contents real apps don't — and every other UI test launches
/// with `UI_TESTING`, which gates the GIF animation off so XCUITest's idle
/// detection stays fast.
///
/// This class deliberately launches WITHOUT that argument and pays the
/// idle-detection cost of a continuously-animating CADisplayLink. It is
/// quarantined here so the rest of the suite keeps its fast gated launch —
/// keep it to the minimum tests that need real rendering.
final class GIFRenderingUITests: UITestCase {

    // Inherits launchArguments == [] — the GIF must actually animate.

    func test_gifBanner_visiblyAnimates() {
        openModule("Image Loading", until: app.navigationBars["Image Loading"])
        let gif = app.images["gifImage"]
        XCTAssertTrue(gif.waitForExistence(timeout: uiTimeout), "the GIF banner image must render")

        // Two element screenshots a beat apart must differ while the GIF
        // animates. The element rect excludes the status bar and the rest of
        // the screen, so only GIF pixels can satisfy (or fail) the check.
        // Retry once before failing — a same-frame coincidence gets re-shot.
        for attempt in 0..<2 {
            let first = gif.screenshot().pngRepresentation
            Thread.sleep(forTimeInterval: 0.6)
            let second = gif.screenshot().pngRepresentation
            if first != second { return }
            if attempt == 0 { continue }
        }
        XCTFail("the GIF banner did not visibly animate — screenshots are pixel-identical (display-suppression bug class)")
    }
}
