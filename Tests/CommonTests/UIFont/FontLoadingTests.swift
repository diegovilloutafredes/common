import UIKit
import XCTest
@testable import Common

/// End-to-end verification that a bundled custom font actually registers and
/// resolves through the public `appFont` API — i.e. that the `"Family-Style"`
/// PostScript convention holds and the system fallback is *not* silently used.
///
/// `VarelaRound-Regular.ttf` is bundled into this test target (Resources/) and
/// registered at runtime via `CTFontManagerRegisterGraphicsFont`.
final class FontLoadingTests: XCTestCase {

    private let varelaRound = TestFonts.varelaRound

    override func setUp() {
        super.setUp()
        // Registers once per process via the bulk API and fails LOUDLY if a
        // genuine registration error is swallowed (see TestFonts).
        TestFonts.ensureVarelaRoundRegistered()
    }

    override func tearDown() {
        super.tearDown()
        UIFont.setPrimaryFamily(nil)
    }

    func test_registeredFont_resolvesByPostScriptName() {
        let font = UIFont(name: "VarelaRound-Regular", size: 12)
        XCTAssertNotNil(font, "Custom font failed to register/resolve by its PostScript name")
        XCTAssertEqual(font?.fontName, "VarelaRound-Regular")
    }

    func test_appFont_returnsCustomFace_notSystemFallback() {
        let font = UIFont.appFont(varelaRound, style: .regular, size: 12)
        XCTAssertEqual(font.fontName, "VarelaRound-Regular",
                       "appFont(_:style:size:) fell back to the system font instead of the custom face")
        XCTAssertEqual(font.pointSize, 12)
    }
}
