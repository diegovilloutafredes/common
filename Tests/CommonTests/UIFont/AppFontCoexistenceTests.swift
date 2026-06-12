//
//  AppFontCoexistenceTests.swift
//

import UIKit
import XCTest
@testable import Common

// Replicates the pre-AppFontFamily app-side pattern (an app-local `appFont`
// helper with a defaulted family parameter). Lives at file scope so overload
// resolution sees it exactly as a consuming app's extension.
private enum LegacyFamily: String, Uppercaseable, CaseIterable {
    case montserrat
}

private let legacyMarkerSize: CGFloat = 99

extension UIFont {
    fileprivate static func appFont(_ family: LegacyFamily = .montserrat, style: FontStyle = .regular, size: CGFloat) -> UIFont {
        // Marker font: lets the tests detect that THIS helper was chosen.
        .italicSystemFont(ofSize: legacyMarkerSize)
    }
}

/// Common gained `appFont(style:size:)`, which overlaps the label-only call
/// shape of app-local legacy helpers. Common's overload is `@_disfavoredOverload`
/// so existing apps keep resolving to their own helper — otherwise their fonts
/// silently fall back to the system font (unset primary family).
final class AppFontCoexistenceTests: XCTestCase {

    override func tearDown() {
        UIFont.setPrimaryFamily(nil)
        super.tearDown()
    }

    func test_labelOnlyCallSites_resolveToLocalLegacyHelper() {
        XCTAssertEqual(UIFont.appFont(style: .bold, size: 14).pointSize, legacyMarkerSize)
        XCTAssertEqual(UIFont.appFont(size: 12).pointSize, legacyMarkerSize)
    }

    func test_explicitLegacyFamily_resolvesToLocalLegacyHelper() {
        XCTAssertEqual(UIFont.appFont(.montserrat, size: 18).pointSize, legacyMarkerSize)
    }

    func test_explicitAppFontFamily_resolvesToCommonOverload() {
        let font = UIFont.appFont(AppFontFamily(rawValue: "NonExistentFamily"), style: .regular, size: 16)
        XCTAssertEqual(font.pointSize, 16, "AppFontFamily-typed calls must keep resolving to Common's implementation")
    }
}
