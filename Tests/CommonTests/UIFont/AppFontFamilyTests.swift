import UIKit
import XCTest
@testable import Common

final class AppFontFamilyTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        UIFont.setPrimaryFamily(nil)
    }

    // MARK: - AppFontFamily.uppercasingFirstLetter

    func test_singleWordFamily_uppercasesFirstLetter() {
        XCTAssertEqual(AppFontFamily(rawValue: "montserrat").uppercasingFirstLetter, "Montserrat")
        XCTAssertEqual(AppFontFamily(rawValue: "inter").uppercasingFirstLetter, "Inter")
    }

    func test_camelCaseFamily_preservesInternalCasing() {
        XCTAssertEqual(AppFontFamily(rawValue: "varelaRound").uppercasingFirstLetter, "VarelaRound")
        XCTAssertEqual(AppFontFamily(rawValue: "openSans").uppercasingFirstLetter, "OpenSans")
    }

    func test_alreadyPascalCaseFamily_unchanged() {
        XCTAssertEqual(AppFontFamily(rawValue: "Montserrat").uppercasingFirstLetter, "Montserrat")
    }

    // MARK: - FontStyle.uppercasingFirstLetter

    func test_fontStyleUppercasesFirstLetter() {
        XCTAssertEqual(UIFont.FontStyle.bold.uppercasingFirstLetter,      "Bold")
        XCTAssertEqual(UIFont.FontStyle.semiBold.uppercasingFirstLetter,  "SemiBold")
        XCTAssertEqual(UIFont.FontStyle.extraBold.uppercasingFirstLetter, "ExtraBold")
        XCTAssertEqual(UIFont.FontStyle.regular.uppercasingFirstLetter,   "Regular")
        XCTAssertEqual(UIFont.FontStyle.italic.uppercasingFirstLetter,    "Italic")
    }

    func test_allStylesProduceNonEmptySuffix() {
        for style in UIFont.FontStyle.allCases {
            XCTAssertFalse(
                style.uppercasingFirstLetter.isEmpty,
                "FontStyle.\(style) produces an empty PostScript suffix"
            )
        }
    }

    // PostScript-name composition ("Family-Style") is exercised end-to-end against a real
    // registered font in FontLoadingTests, which drives the production resolver rather than
    // re-implementing the interpolation inline.

    // MARK: - UIFont.appFont(_:style:size:) — fallback

    func test_unknownFamily_regularStyle_fallsBackToPlainSystemFont() {
        let font = UIFont.appFont(AppFontFamily(rawValue: "NonExistentFamily"), style: .regular, size: 16)
        XCTAssertEqual(font.pointSize, 16)
        // fontName (not just pointSize): a fallback that routed .regular through
        // boldSystemFont would still be 16pt.
        XCTAssertEqual(font.fontName, UIFont.systemFont(ofSize: 16).fontName)
    }

    func test_unknownFamily_boldStyle_returnsBoldSystemFont() {
        let font = UIFont.appFont(AppFontFamily(rawValue: "NonExistentFamily"), style: .bold, size: 18)
        XCTAssertEqual(font.pointSize, 18)
        XCTAssertEqual(font.fontDescriptor.symbolicTraits.contains(.traitBold), true)
    }

    func test_unknownFamily_italicStyle_returnsItalicSystemFont() {
        let font = UIFont.appFont(AppFontFamily(rawValue: "NonExistentFamily"), style: .italic, size: 14)
        XCTAssertEqual(font.pointSize, 14)
        XCTAssertEqual(font.fontDescriptor.symbolicTraits.contains(.traitItalic), true)
    }

    // MARK: - UIFont.appFont(style:size:) — primary family

    // These three drive the primary-family routing against the REALLY-registered
    // VarelaRound fixture. Using an unresolvable family here is a tautology: its
    // fallback output is byte-identical to the no-primary path, so a no-op
    // setPrimaryFamily would pass.

    func test_noPrimaryFamily_fallsBackToPlainSystemFont() {
        UIFont.setPrimaryFamily(nil)
        let font = UIFont.appFont(style: .regular, size: 13)
        XCTAssertEqual(font.pointSize, 13)
        XCTAssertEqual(font.fontName, UIFont.systemFont(ofSize: 13).fontName)
    }

    func test_setPrimaryFamily_subsequentCallsResolveThatFamily() {
        TestFonts.ensureVarelaRoundRegistered()
        UIFont.setPrimaryFamily(TestFonts.varelaRound)

        let font = UIFont.appFont(style: .regular, size: 20)

        XCTAssertEqual(font.fontName, TestFonts.postScriptName,
                       "appFont(style:size:) must route through the primary family, not the system fallback")
        XCTAssertEqual(font.pointSize, 20)
    }

    func test_setPrimaryFamilyNil_clearsRegistration() {
        TestFonts.ensureVarelaRoundRegistered()
        UIFont.setPrimaryFamily(TestFonts.varelaRound)
        UIFont.setPrimaryFamily(nil)

        let font = UIFont.appFont(style: .regular, size: 11)

        XCTAssertNotEqual(font.fontName, TestFonts.postScriptName,
                          "clearing the primary family must stop resolving to it")
        XCTAssertEqual(font.fontName, UIFont.systemFont(ofSize: 11).fontName)
    }
}
