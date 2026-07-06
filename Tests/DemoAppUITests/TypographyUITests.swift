import XCTest

// MARK: - TypographyUITests

final class TypographyUITests: UITestCase {

    override func setUp() {
        super.setUp()
        openModule("Typography", until: app.navigationBars["Typography"])
    }

    // MARK: - PaddingLabel demo badge renders

    func test_typography_showsPaddingLabelBadge() {
        let badge = app.staticTexts["PaddingLabel"]
        XCTAssertTrue(
            badge.waitForExistence(timeout: uiTimeout),
            "PaddingLabel demo badge should render on the Typography screen"
        )
        // Existence alone can't fail for layout defects — a zero-sized or
        // collapsed badge still "exists". The badge sits above the fold in a
        // fixed layout, so these are flake-safe. (Exact size deltas are
        // device/scale-dependent and deliberately NOT asserted here.)
        XCTAssertTrue(badge.isHittable, "the badge must actually be laid out on screen")
        XCTAssertGreaterThan(badge.frame.width, 0)
        XCTAssertGreaterThan(badge.frame.height, 0)
    }

    // MARK: - Family chip selection rebuilds the preview

    /// The chip tap → didSelectFamily → reloadPreview wiring exists only at the
    /// UI layer (.onTap on configuration buttons) — no unit test can catch a
    /// broken chip handler.
    func test_typography_tappingFamilyChip_updatesPreviewTitle() {
        // Configuration-based UIButtons expose their titles as descendant
        // staticTexts, so each family name matches its CHIP even before it is
        // selected. Counts are what change: selecting a family adds its preview
        // title label (chip + preview = 2) and drops the previous family back
        // to chip-only (1).
        func matches(_ label: String) -> XCUIElementQuery {
            app.staticTexts.matching(NSPredicate(format: "label == %@", label))
        }
        XCTAssertTrue(app.staticTexts["Montserrat"].waitForExistence(timeout: uiTimeout))
        XCTAssertEqual(matches("Montserrat").count, 2, "at launch: Montserrat chip + Montserrat preview title")
        XCTAssertEqual(matches("Inter").count, 1, "at launch: the Inter chip only")

        app.buttons["Inter"].tap()

        let previewSwitched = NSPredicate { _, _ in matches("Inter").count == 2 }
        wait(for: [XCTNSPredicateExpectation(predicate: previewSwitched, object: nil)], timeout: uiTimeout)
        XCTAssertEqual(matches("Inter").count, 2, "after selection: Inter chip + Inter preview title")
        XCTAssertEqual(matches("Montserrat").count, 1, "the previous preview title should be gone (chip remains)")
    }
}
