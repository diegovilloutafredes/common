//
//  FontRegisterErrorTests.swift
//

import UIKit
import XCTest
@testable import Common

/// Verifies that a failed `CTFontManagerRegisterGraphicsFont` registration is
/// surfaced as `.registerFailed` carrying the underlying `CFError` description.
final class FontRegisterErrorTests: XCTestCase {

    func test_duplicateRegistration_throwsRegisterFailedWithDescription() {
        let bundle = Bundle(for: Self.self)

        // Font registration is process-global: the first registration may have
        // already happened in another test (e.g. FontLoadingTests). Ensure it.
        try? UIFont.register("VarelaRound-Regular", type: "ttf", on: bundle)

        XCTAssertThrowsError(try UIFont.register("VarelaRound-Regular", type: "ttf", on: bundle)) { error in
            guard case let UIFont.RegisterFontError.registerFailed(description) = error else {
                return XCTFail("Expected .registerFailed, got \(error)")
            }
            XCTAssertNotNil(description)
            XCTAssertFalse(description?.isEmpty ?? true, "CFError description should carry the Core Text failure reason")
        }
    }

    func test_missingFontFile_throwsFontPathNotFound() {
        XCTAssertThrowsError(try UIFont.register("DoesNotExist", type: "ttf", on: Bundle(for: Self.self))) { error in
            guard case UIFont.RegisterFontError.fontPathNotFound = error else {
                return XCTFail("Expected .fontPathNotFound, got \(error)")
            }
        }
    }
}
