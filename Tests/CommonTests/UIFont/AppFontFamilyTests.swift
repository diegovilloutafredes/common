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

    // MARK: - PostScript name composition

    func test_postScriptNameComposedFromFamilyAndStyle() {
        let family = AppFontFamily(rawValue: "montserrat")
        let name = "\(family.uppercasingFirstLetter)-\(UIFont.FontStyle.bold.uppercasingFirstLetter)"
        XCTAssertEqual(name, "Montserrat-Bold")
    }

    func test_postScriptNameAllStyleVariants() {
        let family = AppFontFamily(rawValue: "inter")
        let expectations: [(UIFont.FontStyle, String)] = [
            (.regular,   "Inter-Regular"),
            (.bold,      "Inter-Bold"),
            (.semiBold,  "Inter-SemiBold"),
            (.light,     "Inter-Light"),
            (.italic,    "Inter-Italic"),
            (.extraBold, "Inter-ExtraBold"),
        ]
        for (style, expected) in expectations {
            let name = "\(family.uppercasingFirstLetter)-\(style.uppercasingFirstLetter)"
            XCTAssertEqual(name, expected)
        }
    }

    // MARK: - UIFont.appFont(family:style:size:) — fallback

    func test_unknownFamily_returnsNonNilFontAtRequestedSize() {
        let font = UIFont.appFont(family: AppFontFamily(rawValue: "NonExistentFamily"), style: .regular, size: 16)
        XCTAssertEqual(font.pointSize, 16)
    }

    func test_unknownFamily_boldStyle_returnsBoldSystemFont() {
        let font = UIFont.appFont(family: AppFontFamily(rawValue: "NonExistentFamily"), style: .bold, size: 18)
        XCTAssertEqual(font.pointSize, 18)
        XCTAssertEqual(font.fontDescriptor.symbolicTraits.contains(.traitBold), true)
    }

    func test_unknownFamily_italicStyle_returnsItalicSystemFont() {
        let font = UIFont.appFont(family: AppFontFamily(rawValue: "NonExistentFamily"), style: .italic, size: 14)
        XCTAssertEqual(font.pointSize, 14)
        XCTAssertEqual(font.fontDescriptor.symbolicTraits.contains(.traitItalic), true)
    }

    // MARK: - UIFont.appFont(style:size:) — primary family

    func test_noPrimaryFamily_returnsSystemFontAtRequestedSize() {
        UIFont.setPrimaryFamily(nil)
        let font = UIFont.appFont(style: .regular, size: 13)
        XCTAssertEqual(font.pointSize, 13)
    }

    func test_setPrimaryFamily_subsequentCallsUseThatFamily() {
        UIFont.setPrimaryFamily(AppFontFamily(rawValue: "NonExistentFamily"))
        let font = UIFont.appFont(style: .bold, size: 20)
        XCTAssertEqual(font.pointSize, 20)
        XCTAssertEqual(font.fontDescriptor.symbolicTraits.contains(.traitBold), true)
    }

    func test_setPrimaryFamilyNil_clearsRegistration() {
        UIFont.setPrimaryFamily(AppFontFamily(rawValue: "SomeFamily"))
        UIFont.setPrimaryFamily(nil)
        let font = UIFont.appFont(style: .regular, size: 11)
        XCTAssertEqual(font.pointSize, 11)
    }
}
