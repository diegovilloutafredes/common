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

    private let varelaRound = AppFontFamily(rawValue: "varelaRound")

    override func setUp() {
        super.setUp()
        // Process-global registration; the bulk variant logs and swallows the
        // "already registered" error on repeat runs, so this is idempotent.
        UIFont.register(fonts: [varelaRound], styles: [.regular], on: Bundle(for: Self.self))
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
