//
//  FontTestSupport.swift
//

import UIKit
import XCTest
@testable import Common

private final class FontBundleToken {}

enum TestFonts {

    static let varelaRound = AppFontFamily(rawValue: "varelaRound")
    static let postScriptName = "VarelaRound-Regular"

    /// Registers the bundled `VarelaRound-Regular.ttf` once per process, via the
    /// production BULK API (`register(fonts:styles:on:)`) so its "Family-Style"
    /// filename composition stays under end-to-end test.
    ///
    /// Font registration is process-global `CTFontManager` state, so this is
    /// probe-guarded (no repeat registration → no swallowed error-305 noise)
    /// and LOUD on genuine failure: the bulk API logs-and-swallows its errors,
    /// which would otherwise let a real failure (renamed resource, corrupt
    /// file) hide behind the routine "already registered" log line.
    static func ensureVarelaRoundRegistered(file: StaticString = #filePath, line: UInt = #line) {
        if UIFont(name: postScriptName, size: 12) == nil {
            UIFont.register(fonts: [varelaRound], styles: [.regular], on: Bundle(for: FontBundleToken.self))
        }
        if UIFont(name: postScriptName, size: 12) == nil {
            XCTFail("\(postScriptName) failed to register — the bulk register(fonts:) swallowed a genuine error",
                    file: file, line: line)
        }
    }
}
